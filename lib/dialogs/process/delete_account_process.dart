import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:hive/hive.dart';

///LOGIN PROCESS:
///
/// Login by form triggers sign in fireAuth and login services process:
///
///  - PpUserService login - stores current signed in user nickname
///  #first bcs anything else needs nickname
///
///  - ContactsService login - stores contacts nicknames, contacts User objects with streams,
///  streams triggers events like add/delete conversation (delete account also)
///  stores contacts user objects Stream Controllers
///
///  - ConversationService - stores conversations for each contact,
///  stores Messages collection subscription, listens to contacts events,
///  #after contacts bcs needs contacts
///
///  - PpNotificationService login - stores subscription of notifications collection,
///  login triggers operations sent by other side users as notifications (invitation, clear conversation clear)
///  #last bcs needs access to data stored by other services


///LOGOUT PROCESS:
///
/// Triggered by fireAuth listener or logout button. First logout services:
/// at the moment have no access to uid
///
///  - ConversationService - reset data about conversation,
///
///  - ContactsService - reset data about contacts,
///
///  - PpNotificationService - reset data about notifications
///
/// - PpUserService - reset data about user - set login status to firestore if have access


class DeleteAccountProcess extends LogProcess {

  final _userService = getIt.get<PpUserService>();
  final _contactsService = getIt.get<ContactsService>();
  final _conversationService = getIt.get<ConversationService>();
  final _notificationService = getIt.get<PpNotificationService>();
  final _authenticationService = getIt.get<AuthenticationService>();
  final _state = getIt.get<States>();

  final _fireAuth = FirebaseAuth.instance;

  List<String> _contactUids = [];
  String _uid = '';

  late List<PpUser> _contacts;


  WriteBatch? firestoreDeleteAccountBatch;
  int batchValue = 0;

  DeleteAccountProcess() {
    _contacts = _state.contacts.get.map((c) => c).toList();
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

  _batchSet({required DocumentReference documentReference, required Map<String, dynamic> data}) async {
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
      await firestoreDeleteAccountBatch!.commit().onError((error, stackTrace) {});
      log('[STOP] BATCH COMMIT');
      batchValue = 0;
    } else {
      throw Exception('NO BATCH!');
    }
  }


  process() async {
    super.setProcess('DeleteAccountProcess');
    try {

      super.setContext(_state.me.nickname);
      log('[nickname: $_state.me.nickname]');

      if (_fireAuth.currentUser != null) {
        _uid = _fireAuth.currentUser!.uid;
      } else {
        _uid = 'NO FIRE AUTH UID!!';
      }

      _contactUids = _state.contactUids.get;
      log('${_contactUids.length} contact nicknames found');

      await _addDeletedAccountLogBatch();

      await _deleteHiveConversationsData();

      await _prepareBatch();

      await _batchCommit();
      //after this no access to firestore data anymore
      //only stored here remains like nickname, uid, contactUids

      await _resetServices();

      await save();

      super.popup.show('Delete account successful!');

    } catch (error) {
      errorHandler(error);
    }
  }

  _addDeletedAccountLogBatch() {
    final documentReference = firestore
        .collection(Collections.DELETED_ACCOUNTS).doc(_state.me.nickname);

    final data = {'uid': _uid, 'nickname': _state.me.nickname};

    _batchSet(documentReference: documentReference, data: data);
  }


  _deleteHiveConversationsData() async {
    await Hive.deleteFromDisk();
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
      await _batchSet(
          documentReference: _contactsService.contactNotificationDocRef(contactUid: contact.uid),
          data: PpNotification.createContactDeleted(
              sender: _state.me.nickname,
              receiver: contact.nickname,
              documentId: States.getUid!
          ).asMap);
      log('Notification for ${contact.nickname} prepared');
    }
    log('[STOP] Prepare batch - send notifications to contacts');

    // for (var contactNickname in _contactsNicknames) {
    //   await _batchSet(
        // documentReference: _contactsService.contactNotificationDocRef(contactUid: contactNickname),
        // data: PpNotification.createContactDeleted(sender: _nickname, receiver: contactNickname, documentId: _state.me.signature).asMap
      // );
      // log('Notification for $contactNickname prepared');
    // }
    // log('[STOP] Prepare batch - send notifications to contacts');
  }

  _prepareBatchDeleteSentMessagesToContacts() async {
    log('[START] Prepare batch - delete sent messages to contacts [Messages]');
    for (var contact in _contacts) {
      final contactMessagesCollectionQuerySnapshot = await _conversationService
          .contactMessagesCollectionRef(contactUid: contact.uid)
          .where(PpMessageFields.sender, isEqualTo: _state.me.nickname).get();
      log('${contactMessagesCollectionQuerySnapshot.docs.length} unread messages to delete found for ${contact.nickname}.');

      for (var doc in contactMessagesCollectionQuerySnapshot.docs) {
        await _batchDelete(doc.reference);
      }
      log('[STOP] Prepare batch - delete sent messages to contacts');
    }
    // for (var contactNickname in _contactsNicknames) {
      // final contactMessagesCollectionQuerySnapshot = await _conversationService.contactMessagesCollectionRef(contactUid: '')
      //     .where(PpMessageFields.sender, isEqualTo: _nickname).get();
      // log('${contactMessagesCollectionQuerySnapshot.docs.length} unread messages to delete found for $contactNickname.');
      //
      // for (var doc in contactMessagesCollectionQuerySnapshot.docs) {
      //   await _batchDelete(doc.reference);
      // }
    //
    // }
    // log('[STOP] Prepare batch - delete sent messages to contacts');
  }

  _prepareBatchDeleteContacts() async {
    log('[START] Prepare batch - delete contacts [CONTACTS]');
    await _batchDelete(_state.contactUids.documentRef);
    log('[STOP] Prepare batch - delete contacts [CONTACTS]');
  }

  _prepareBatchDeleteUnreadMessages() async {
    log('[START] Prepare batch - delete messages [Messages]');
    //sent
    final messages = await _conversationService.messagesCollectionRef.get();
    log('${messages.docs.length} messages found to delete.');
    for (var message in messages.docs) {
      await _batchDelete(message.reference);
    }
    log('[STOP] Prepare batch - delete messages [Messages]');
  }

  _prepareBatchDeleteNotifications() async {
    log('[START] Prepare batch - delete notifications [NOTIFICATIONS]');
    final notificationsCollectionQuerySnapshot = await _state.notifications.collectionRef.get();
    log('${notificationsCollectionQuerySnapshot.docs.length} notifications found to delete.');
    for (var notification in notificationsCollectionQuerySnapshot.docs) {
      await _batchDelete(notification.reference);
    }
    log('[STOP] Prepare batch - delete notifications [NOTIFICATIONS]');
  }

  _prepareBatchDeleteUser() async {
    log('[START] Prepare batch - delete user [User][PRIVATE]');
    await _batchDelete(firestore.collection(Collections.PpUser).doc(States.getUid));
    // await _batchDelete(firestore.collection(Collections.PpUser).doc(States.getUid).collection(Collections.PRIVATE).doc(States.getUid));
    log('[STOP] Prepare batch - delete user [User][PRIVATE]');
  }


  _resetServices() async {
    log('[START] Reset services.');

    await _notificationService.logout();
    log('PpNotificationService clean!');

    await _conversationService.logout();
    log('ConversationService clean!');

    await _contactsService.logout();
    log('ContactsService clean!');

    await _userService.logout(skipFirestore: true);
    log('PpUserService clean!');

    await _authenticationService.signOut();
    log('fireAuth signed out!');

    log('[STOP] Reset services.');
  }

}