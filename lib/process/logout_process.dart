import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';

class LogoutProcess extends LogProcess {

  final conversationService = getIt.get<ConversationService>();
  final userService = getIt.get<PpUserService>();

  process() async {
    log('[LogoutProcess] [START]');
    await userService.updateLogged(false);
    await stopListeners();
    clearData();
    log('[LogoutProcess] [STOP]');
  }

  stopListeners() async {
    await conversationService.stopMessagesObserver();
    await Notifications.reference.stopNotificationsListener();
    await Notifications.reference.stopFirestoreObserver();
    await Contacts.reference.stopContactUidsListener();
    await ContactUids.reference.stopFirestoreObserver();
    await Contacts.reference.stopFirestoreObserver();
    await Me.reference.stopFirestoreObserver();
    log('[LogoutProcess] stopListeners');
  }

  clearData() {
    conversationService.clearConversations();
    Notifications.reference.clear();
    ContactUids.reference.clear();
    Contacts.reference.clear();
    Me.reference.clear();
  }
}