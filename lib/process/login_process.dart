import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';

class LoginProcess extends LogProcess {

  process() async {
    log('[LoginProcess] [START]');

    await Me.reference.startFirestoreObserver();
    log('[LoginProcess] [Me] initialized');

    await ContactUids.reference.startFirestoreObserver();
    log('[LoginProcess] [ContactUids] initialized');

    await Contacts.reference.start(); //includes startFirestoreObserver
    log('[LoginProcess] [Contacts] initialized');

    await Notifications.reference.start();
    log('[LoginProcess] [Notifications] initialized');

    final conversationService = getIt.get<ConversationService>();
    await conversationService.login();
    log('[LoginProcess] [Conversations] initialized');

    log('[LoginProcess] [STOP]');
  }

}