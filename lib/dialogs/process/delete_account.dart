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



class DeleteAccountEvent extends LogProcess{

    final _userService = getIt.get<PpUserService>();
    final _contactsService = getIt.get<ContactsService>();
    final _conversationService = getIt.get<ConversationService>();
    final _notificationService = getIt.get<PpNotificationService>();

    List<String> _contactsNicknames = [];
    String _nickname = '';

  DeleteAccountEvent() {
    startProcess();
  }

  @override
  firstLog() {
    log('STARTING DELETE ACCOUNT PROCESS');
  }

  startProcess() async {
    log('start');
    try {

      _nickname = _userService.nickname;

      _getContactsNicknames();

      await _deleteHiveConversationsData();

      //after this no access to contacts anymore - only stored here contactNicknames
      await _firestoreBatchProcess();
      //  TODO prepare limit to 500 batches per commit

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
    log('${_contactsNicknames.length} nicknames get.');
    log('[STOP] Getting contacts nicknames.');
  }


  _deleteHiveConversationsData() {
    log('[START] Delete HIVE conversation data.');

    log('[STOP] Delete HIVE conversation data.');
  }


  _firestoreBatchProcess() async {
    log('[START] FIRESTORE BATCH PROCESS - delete account.');
    final batch = firestore.batch();

    for (var contactNickname in _contactsNicknames) {
      batch.set(_contactsService.getNotificationReceiverDocRef(contactNickname),
          PpNotification.createContactDeleted(
              sender: _userService.nickname, receiver: contactNickname).asMap);
      log('Notification for $contactNickname prepared');

      final contactMessagesCollectionQuerySnapshot = await _conversationService.getContactMessagesRef(contactNickname)
          .where(PpMessageFields.sender, isEqualTo: _userService.nickname)
          .get();

      log('Messages collection snapshot prepared for $contactNickname');
      log('${contactMessagesCollectionQuerySnapshot.docs.length} messages found.');
      if (contactMessagesCollectionQuerySnapshot.docs.isNotEmpty) {
        for (var doc in contactMessagesCollectionQuerySnapshot.docs) {
          batch.delete(doc.reference);
        }
        log('${contactMessagesCollectionQuerySnapshot.docs.length} message deletes prepared to batch.');
      }

    }
    log('CONTACTS BATCHES PREPARED');

    //CONTACTS
    batch.delete(_contactsService.contactNicknamesDocRef);
    log('Delete contactNicknames document (CONTACTS collection) added to batch');

    //MESSAGES
    log('Looking for messages collection:');
    final currentMessages = await _conversationService.messagesCollectionRef.get();
    log('${currentMessages.docs.length} messages found to delete.');
    if (currentMessages.docs.isNotEmpty) {
      for (var message in currentMessages.docs) {
        batch.delete(message.reference);
      }
      log('${currentMessages.docs.length} messages deletes prepared to batch!');
    }

    //NOTIFICATIONS
    final notifications = _notificationService.currentNotifications;
    log('${notifications.length} notifications found to delete!');

    if (notifications.isNotEmpty) {
      for (var notification in notifications) {
        _notificationService.myNotificationsCollectionRef.doc();
        batch.delete(_notificationService.myNotificationsCollectionRef.doc(_getDocName(notification)));
      }
      log('${notifications.length} notification deletes prepared to batch!');
    }

    //User
    batch.delete(firestore.collection(Collections.User).doc(_nickname));
    batch.delete(firestore.collection(Collections.User).doc(_nickname).collection(Collections.PRIVATE).doc(_nickname));
    log('Prepared User document delete batch');

    log('Batch prepared.');

    await batch.commit();
    log('[STOP] FIRESTORE BATCH PROCESS - delete account.');
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