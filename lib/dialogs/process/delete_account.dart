import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:hive_flutter/adapters.dart';

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

  final _fireAuth = FirebaseAuth.instance;

  List<String> _contactsNicknames = [];
  String _nickname = '';
  String _uid = '';


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

  _batch(DocumentReference ref) async {
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
      log('[START] BATCH COMMIT.');
      await firestoreDeleteAccountBatch!.commit();
      log('[STOP] BATCH COMMIT.');
      batchValue = 0;
    } else {
      throw Exception('NO BATCH!');
    }
  }


  startProcess() async {
    try {

      _nickname = _userService.nickname;
      log('[nickname: $_nickname]');

      if (_fireAuth.currentUser != null) {
        _uid = _fireAuth.currentUser!.uid;
      } else {
        _uid = 'NO FIRE AUTH UID!!';
      }

      _getContactsNicknames();

      await _addDeletedAccountLog();

      await _deleteHiveConversationsData();

      await _prepareBatch();

      await _batchCommit();
      //after this no access to firestore data anymore
      //only stored here remains like nickname, uid, contactNicknames

      await _resetServices();

      save();

    } catch (error) {
      print(error);
      print(error.runtimeType);
      logs.add(error.toString());
      logs.add('error type: ${error.runtimeType.toString()}');
      save();
    }
  }

  _addDeletedAccountLog() async {
    await firestore.collection(Collections.DELETED_ACCOUNTS)
        .doc(_userService.nickname)
        .set({'uid': _uid, 'nickname': _nickname});
  }


  _getContactsNicknames() {
    log('[START] Getting contacts nicknames.');
    _contactsNicknames = _contactsService.currentContactNicknames;
    log('[STOP] Getting contacts nicknames. ${_contactsNicknames.length} found.');
  }


  _deleteHiveConversationsData() async {
    log('[START] Delete HIVE conversation data.');
    if (_conversationService.conversationsBoxes.isNotEmpty) {
      log('${_conversationService.conversationsBoxes.length} conversation boxes to close');

      for(var key in _conversationService.conversationsBoxes.keys) {
        if (Hive.isBoxOpen(key)) {
          log('Closing and deleting box for $key');
          await _conversationService.conversationsBoxes[key]!.close();
          await Hive.deleteBoxFromDisk(key);
        } else {
          log('There was no open box for $key');
        }
      }
      log('Deleting HIVE from disk');
      await Hive.deleteFromDisk();
    }
    log('[STOP] Delete HIVE conversation data.');
  }



  _prepareBatch() async {
    log('[START] FIRESTORE BATCH PREPARATION');

    await _prepareBatchSendNotifications();

    await _prepareBatchDeleteSentMessagesToContacts();

    await _prepareBatchDeleteContacts();

    await _prepareBatchDeleteMessages();

    await _prepareBatchDeleteNotifications();

    await _prepareBatchDeleteUser();

    log('[STOP] FIRESTORE BATCH PREPARATION');
  }



  _prepareBatchSendNotifications() async {
    log('[START] Prepare batch - send notifications to contacts [NOTIFICATIONS]');
    for (var contactNickname in _contactsNicknames) {
      await _batchSet(
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
        await _batch(doc.reference);
      }

    }
    log('[STOP] Prepare batch - delete sent messages to contacts');
  }

  _prepareBatchDeleteContacts() async {
    log('[START] Prepare batch - delete contacts [CONTACTS]');
    await _batch(_contactsService.contactNicknamesDocRef);
    log('[STOP] Prepare batch - delete contacts [CONTACTS]');
  }

  _prepareBatchDeleteMessages() async {
    log('[START] Prepare batch - delete messages [Messages]');
    final messages = await _conversationService.messagesCollectionRef.get();
    log('${messages.docs.length} messages found to delete.');
    for (var message in messages.docs) {
      await _batch(message.reference);
    }
    log('[STOP] Prepare batch - delete messages [Messages]');
  }

  _prepareBatchDeleteNotifications() async {
    log('[START] Prepare batch - delete notifications [NOTIFICATIONS]');
    final notifications = await _notificationService.myNotificationsCollectionRef.get();
    log('${notifications.docs.length} notifications found to delete.');
    for (var notification in notifications.docs) {
      await _batch(notification.reference);
    }
    log('[STOP] Prepare batch - delete notifications [NOTIFICATIONS]');
  }

  _prepareBatchDeleteUser() async {
    log('[START] Prepare batch - delete user [User][PRIVATE]');
    await _batch(firestore.collection(Collections.User).doc(_nickname));
    await _batch(firestore.collection(Collections.User).doc(_nickname).collection(Collections.PRIVATE).doc(_nickname));
    log('[STOP] Prepare batch - delete user [User][PRIVATE]');
  }




  _resetServices() async {

  }


  //TODO: another process for receive deleted account notification
  //  deletes Messages collection if exists

}