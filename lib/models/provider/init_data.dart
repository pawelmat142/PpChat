import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';

class InitData extends LogProcess {
  final BuildContext context;

  InitData(this.context);

  process() async {
    log('[InitData] [START]');

    await Me.reference.startFirestoreObserver();
    log('[InitData] [Me] initialized');

    await ContactUids.reference.startFirestoreObserver();
    log('[InitData] [ContactUids] initialized');

    await Contacts.reference.start(); //includes startFirestoreObserver
    log('[InitData] [Contacts] initialized');

    await Notifications.reference.start();
    log('[InitData] [Notifications] initialized');

    final conversationService = getIt.get<ConversationService>();
    await conversationService.login();

    // LoginProcess();

    log('[InitData] [STOP]');
  }

}