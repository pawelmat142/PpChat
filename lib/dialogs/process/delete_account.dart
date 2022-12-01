import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
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



class DeleteAccountEvent extends LogProcess{

    final _userService = getIt.get<PpUserService>();
    final _contactsService = getIt.get<ContactsService>();
    final _conversationService = getIt.get<ConversationService>();
    final _notificationService = getIt.get<PpNotificationService>();

    List<String> _contactsNicknames = [];
    
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
      log('get contact nicknames');
      _contactsNicknames = _contactsService.currentContactNicknames;

      await _sendNotificationsToContacts();

      await _deleteHiveConversationsData();

    } catch (error) {
      print(error);
      logs.add(error.toString());
      save();
    }
  }

  _sendNotificationsToContacts() async {
    log('[START] Sending notifications to contacts.');
    final batch = firestore.batch();

    for (var contactNickname in _contactsNicknames) {
      log('Notification for $contactNickname preparing');
      batch.set(_contactsService.getNotificationReceiverDocRef(contactNickname),
          PpNotification.createContactDeleted(
              sender: _userService.nickname, receiver: contactNickname).asMap);
    }
    log('Notifications batch completed');
    await batch.commit();
    log('[STOP] Sending notifications to contacts.');
  }

  _deleteHiveConversationsData() {
    log('[START] Delete HIVE conversation data.');

    log('[STOP] Delete HIVE conversation data.');
  }


}