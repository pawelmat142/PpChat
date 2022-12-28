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
///  - PpUserService - reset data about user - set login status to firestore if have access


import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';

class LoginProcess extends LogProcess {

  final _notificationService = getIt.get<PpNotificationService>();
  final _conversationsService = getIt.get<ConversationService>();

  LoginProcess() {
    process();
  }

  process() async {
    log('[START] LOGIN PROCESS');

    log('[START] ContactsService initializing');
    // await _contactsService.login();
    log('[STOP] ContactsService initializing');

    log('[START] ConversationsService initializing');
    _conversationsService.login();
    log('[STOP] ConversationsService initializing');

    log('[START] PpNotificationsService initializing');
    await _notificationService.login();
    log('[STOP] PpNotificationsService initializing');

    log('[STOP] LOGIN PROCESS');
  }


}