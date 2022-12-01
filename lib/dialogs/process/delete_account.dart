import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';

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
/// todo: store data about logout by listener?
///
///  - ConversationService - reset data about conversation,
///
///  - ContactsService - reset data about contacts,
///
///  - PpNotificationService - reset data about notifications
///  # almost last bcs may be needed to send some notifications during process byt still needs nickname
///
/// - PpUserService - reset data about user - set login status to firestore if have access



///DELETE ACCOUNT PROESS:
///
/// first all conversations data should be deleted
///send notifications to contacts about deleted accounts
///so not need notification about conversation clear
///clear and delete whole hive data
///clear firestore messages, contacts, notifications
///clear user collection with PRIVATE subcollection
///set log about deleted account
///any notification for contact will by overwritten by contactDeleted notification



class DeleteAccountEvent extends LogProcess {

  final _userService = getIt.get<PpUserService>();
  final _contactsService = getIt.get<ContactsService>();
  final _conversationService = getIt.get<ConversationService>();
  final _notificationService = getIt.get<PpNotificationService>();

  List<String> _contactsNicknames = [];
  String _nickname = '';

  WriteBatch? firestoreDeleteAccountBatch;
  int batchValue = 0;

  DeleteAccountEvent() {
    firestoreDeleteAccountBatch = firestore.batch();
    startProcess();
    firestore.batch();
  }

  @override
  firstLog() {
    log('STARTING DELETE ACCOUNT PROCESS');
  }

  _batch(DocumentReference ref) {
    //  default to delete
    if (firestoreDeleteAccountBatch != null) {
      batchValue++;
      firestoreDeleteAccountBatch!.delete(ref);
    } else {
      throw Exception('NO BATCH!');
    }
  }

  _batchCommit() async {
    if (firestoreDeleteAccountBatch != null) {
      log('[START] BATCH COMMIT.');
      await firestoreDeleteAccountBatch!.commit();
      log('[STOP] BATCH COMMIT.');
      batchValue = 0;
    } else {
      throw Exception('NO BATCH!');
    }
  }

  _batchSet({required DocumentReference documentReference, required Map<String, dynamic> data}) {
    if (firestoreDeleteAccountBatch != null) {
      batchValue++;
      firestoreDeleteAccountBatch!.set(documentReference, data);
    } else {
      throw Exception('NO BATCH!');
    }
  }


  startProcess() async {
    try {

      _nickname = _userService.nickname;

      _getContactsNicknames();

      await _deleteHiveConversationsData();

      //after this no access to contacts anymore - only stored here contactNicknames
      await _prepareBatch();
    //  TODO prepare limit to 500 batches per commit

      await _batchCommit();

      await _resetServices();

      save();

    } catch (error) {
      print(error);
      print(error.runtimeType);
      logs.add(error.toString());
      save();
    }
  }


  _getContactsNicknames() {
    log('[START] Getting contacts nicknames.');
    _contactsNicknames = _contactsService.currentContactNicknames;
    log('[STOP] Getting contacts nicknames. ${_contactsNicknames.length} found.');
  }


  _deleteHiveConversationsData() {
    log('[START] Delete HIVE conversation data.');

    log('[STOP] Delete HIVE conversation data.');
  }

  _prepareBatch() async {
    log('[START] FIRESTORE BATCH PREPARATION');
    final batch = firestore.batch();

    _prepareBatchSendNotifications();

    await _prepareBatchDeleteSentMessagesToContacts();

    _prepareBatchDeleteContacts();

    await _prepareBatchDeleteMessages();

    await _prepareBatchDeleteNotifications();

    _prepareBatchDeleteUser();

    log('[STOP] FIRESTORE BATCH PREPARATION');
  }

  _prepareBatchSendNotifications() {
    log('[START] Prepare batch - send notifications to contacts [NOTIFICATIONS]');
    for (var contactNickname in _contactsNicknames) {
      _batchSet(
        documentReference: _contactsService.getNotificationReceiverDocRef(contactNickname),
        data: PpNotification.createContactDeleted(sender: _nickname, receiver: contactNickname).asMap
      );
      log('Notification for $contactNickname prepared');
    }
    log('[STOP] Prepare batch - send notifications to contacts');
  }

  _prepareBatchDeleteSentMessagesToContacts() async {
    log('[START] Prepare batch - delete sent messages to contacts [Messages]');
    for (var contactNickname in _contactsNicknames) {

      final contactMessagesCollectionQuerySnapshot = await _conversationService.getContactMessagesRef(contactNickname)
          .where(PpMessageFields.sender, isEqualTo: _nickname).get();
      log('${contactMessagesCollectionQuerySnapshot.docs.length} messages found for $contactNickname.');

      for (var doc in contactMessagesCollectionQuerySnapshot.docs) {
        _batch(doc.reference);
      }

    }
    log('[STOP] Prepare batch - delete sent messages to contacts');
  }

  _prepareBatchDeleteContacts() {
    log('[START] Prepare batch - delete contacts [CONTACTS]');
    _batch(_contactsService.contactNicknamesDocRef);
    log('[STOP] Prepare batch - delete contacts [CONTACTS]');
  }

  _prepareBatchDeleteMessages() async {
    log('[START] Prepare batch - delete messages [Messages]');
    final messages = await _conversationService.messagesCollectionRef.get();
    log('${messages.docs.length} messages found to delete.');
    for (var message in messages.docs) {
      _batch(message.reference);
    }
    log('[STOP] Prepare batch - delete messages [Messages]');
  }

  _prepareBatchDeleteNotifications() async {
    log('[START] Prepare batch - delete notifications [NOTIFICATIONS]');
    final notifications = await _notificationService.myNotificationsCollectionRef.get();
    log('${notifications.docs.length} notifications found to delete.');
    for (var notification in notifications.docs) {
      _batch(notification.reference);
    }
    log('[STOP] Prepare batch - delete notifications [NOTIFICATIONS]');
  }

  _prepareBatchDeleteUser() {
    log('[START] Prepare batch - delete user [User][PRIVATE]');
    _batch(firestore.collection(Collections.User).doc(_nickname));
    _batch(firestore.collection(Collections.User).doc(_nickname).collection(Collections.PRIVATE).doc(_nickname));
    log('[STOP] Prepare batch - delete user [User][PRIVATE]');
  }


  _resetServices() async {

  }


  _getDocName(PpNotification notification) {
    return _imSender(notification) ? notification.receiver : notification.sender;
  }

  _imSender(PpNotification notification) {
    return _userService.nickname == notification.sender;
  }

  //TODO: another process for receive deleted account notification
  //  deletes Messages collection if exists

}