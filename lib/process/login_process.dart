import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/services/log_service.dart';

class LoginProcess extends LogProcess {

  final userService = getIt.get<PpUserService>();
  final authService = getIt.get<AuthenticationService>();
  final logService = getIt.get<LogService>();
  final notificationService = getIt.get<PpNotificationService>();

  process() async {
    log('[LoginProcess] [START]');

    try {
      await userService.setLoggedTrue();
    } catch (e) {
      authService.signOut();
      return;
    }

    await Me.reference.startFirestoreObserver();
    await Me.reference.initPrivateKey();
    log('[LoginProcess] [Me] initialized');
    logService.setContext(Me.reference.nickname);

    await ContactUids.reference.startFirestoreObserver();
    log('[LoginProcess] [ContactUids] initialized');

    await Contacts.reference.start(); //includes startFirestoreObserver
    log('[LoginProcess] [Contacts] initialized');

    await Notifications.reference.start();
    log('[LoginProcess] [Notifications] initialized');
    await notificationService.setBadgesNumberToUnreadNotificationsNumber();

    final conversationService = getIt.get<ConversationService>();
    await conversationService.login();
    log('[LoginProcess] [Conversations] initialized');

    log('[LoginProcess] [STOP]');
  }

}