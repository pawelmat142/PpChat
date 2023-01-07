import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/process/logout_process.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/services/uid.dart';


class DeleteAccountProcess extends LogProcess {

  final _contactsService = getIt.get<ContactsService>();
  final _conversationService = getIt.get<ConversationService>();
  final _conversationSettingsService = getIt.get<ConversationSettingsService>();

  final Me me = Me.reference;
  final Contacts contacts = Contacts.reference;
  final ContactUids contactUids = ContactUids.reference;
  final Notifications notifications = Notifications.reference;
  final Conversations conversations = Conversations.reference;


  late String _myUid;
  late String _myNickname;
  late List<PpUser> _contacts;
  List<String> get _contactUids => _contacts.map((c) => c.nickname).toList();

  loadData() {
    _myUid = Uid.get!;
    _myNickname = me.get.nickname;
    _contacts = contacts.get.map((c) => c).toList();
  }

  WriteBatch? firestoreDeleteAccountBatch;
  int batchValue = 0;

  DeleteAccountProcess() {
    firestoreDeleteAccountBatch = firestore.batch();
    process();
  }

  _batchDelete(DocumentReference ref) async {
    //  default to delete
    if (firestoreDeleteAccountBatch != null) {
      batchValue++;
      firestoreDeleteAccountBatch!.delete(ref);
      await _batchOverload();
    } else {
      throw Exception('NO BATCH!');
    }
  }

  _batchSet({required DocumentReference documentReference, required Map<
      String,
      dynamic> data}) async {
    if (firestoreDeleteAccountBatch != null) {
      batchValue++;
      firestoreDeleteAccountBatch!.set(documentReference, data);
      await _batchOverload();
    } else {
      throw Exception('NO BATCH!');
    }
  }

  _batchOverload() async {
    if (batchValue > 480) {
      log('[!!BATCH OVERLOADED!! - will be continued in another one]');
      await _batchCommit();
      firestoreDeleteAccountBatch = firestore.batch();
      batchValue = 0;
      log('CONTINUATION DELETE ACCOUNT PROCESS');
    }
  }


  _batchCommit() async {
    if (firestoreDeleteAccountBatch != null) {
      log('[START] BATCH COMMIT');
      await firestoreDeleteAccountBatch!.commit();
      log('[STOP] BATCH COMMIT');
      batchValue = 0;
    } else {
      throw Exception('NO BATCH!');
    }
  }


  process() async {
    try {
      loadData();
      super.setProcess('DeleteAccountProcess');
      super.setContext(_myNickname);
      log('nickname: $_myNickname');
      log('${_contactUids.length} contacts found');

      await _addDeletedAccountLogBatch();

      await AvatarService.deleteAllAvatarsFromDeviceAndHive();

      for (final contact in _contacts) {
        await _conversationSettingsService.fullDeleteConversation(contactUid: contact.uid);
        log('[${contact.nickname}] conversation and settings deleted!');
      }

      // await _deleteHiveConversationsData();

      await _prepareBatch();

      final logoutProcess = LogoutProcess();
      await logoutProcess.process();

      await _batchCommit();
      //after this no access to firestore data anymore
      //only stored here remains like nickname, uid, contactUids


      await save();

      super.popup.show('Delete account successful!');
    } catch (error) {
      errorHandler(error);
    }
  }

  _addDeletedAccountLogBatch() {
    final documentReference = firestore
        .collection(Collections.DELETED_ACCOUNTS).doc(me.nickname);

    final data = {'uid': _myUid, 'nickname': me.nickname};

    _batchSet(documentReference: documentReference, data: data);
  }


  _prepareBatch() async {
    log('[START] FIRESTORE BATCH PREPARATION');

    await _prepareBatchSendNotifications();

    await _prepareBatchDeleteSentMessagesToContacts();

    await _prepareBatchDeleteContacts();

    await _prepareBatchDeleteUnreadMessages();

    await _prepareBatchDeleteNotifications();

    await _prepareBatchDeleteUser();

    log('[STOP] FIRESTORE BATCH PREPARATION');
  }


  _prepareBatchSendNotifications() async {
    log('[START] Prepare batch - send notifications to contacts [NOTIFICATIONS]');

    for (var contact in _contacts) {
      final data = PpNotification.createContactDeleted(
          sender: _myNickname,
          receiver: contact.nickname).asMap;
      final docRef = _contactsService.contactNotificationDocRef(contactUid: contact.uid);
      await _batchSet(documentReference: docRef, data: data);
      log('Notification for ${contact.nickname} prepared');
    }
    log('[STOP] Prepare batch - send notifications to contacts');
  }

  _prepareBatchDeleteSentMessagesToContacts() async {
    log('[START] Prepare batch - delete sent messages to contacts [Messages]');
    for (var contact in _contacts) {
      final contactMessagesCollectionQuerySnapshot = await _conversationService
          .contactMessagesCollectionRef(contactUid: contact.uid)
          .where(PpMessageFields.sender, isEqualTo: _myUid).get();
      log('${contactMessagesCollectionQuerySnapshot.docs.length} unread messages to delete found for ${contact.nickname}.');

      for (var doc in contactMessagesCollectionQuerySnapshot.docs) {
        await _batchDelete(doc.reference);
      }
      log('[STOP] Prepare batch - delete sent messages to contacts');
    }
  }

  _prepareBatchDeleteContacts() async {
    log('[START] Prepare batch - delete contacts subcollection');
    await _batchDelete(contactUids.documentRef);
    log('[STOP] Prepare batch - delete contacts subcollection');
  }

  _prepareBatchDeleteUnreadMessages() async {
    log('[START] Prepare batch - delete messages [Messages]');
    //sent
    final messages = await ConversationService.messagesCollectionRef.get();
    log('${messages.docs.length} messages found to delete.');
    for (var message in messages.docs) {
      await _batchDelete(message.reference);
    }
    log('[STOP] Prepare batch - delete messages [Messages]');
  }

  _prepareBatchDeleteNotifications() async {
    log('[START] Prepare batch - delete notifications [NOTIFICATIONS]');
    final notificationsCollectionQuerySnapshot = await notifications
        .collectionRef.get();
    log('${notificationsCollectionQuerySnapshot.docs
        .length} notifications found to delete.');
    for (var notification in notificationsCollectionQuerySnapshot.docs) {
      await _batchDelete(notification.reference);
    }
    log('[STOP] Prepare batch - delete notifications [NOTIFICATIONS]');
  }

  _prepareBatchDeleteUser() async {
    log('[START] Prepare batch - delete my PpUser document');
    await _batchDelete(firestore.collection(Collections.PpUser).doc(_myUid));
    log('[STOP] Prepare batch - delete my PpUser document');
  }

}