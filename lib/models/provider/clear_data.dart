import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';

class ClearData extends LogProcess {
  final BuildContext context;

  ClearData(this.context);

  process() async {
    log('[ClearData] [START]');

    final conversationService = getIt.get<ConversationService>();
    await conversationService.logout();

    await stopListeners();

    clearData();

    log('[ClearData] [STOP]');
  }

  stopListeners() async {
    await Notifications.reference.stopNotificationsListener();
    await Notifications.reference.stopFirestoreObserver();
    await Contacts.reference.stopContactUidsListener();
    await ContactUids.reference.stopFirestoreObserver();
    await Contacts.reference.stopFirestoreObserver();
    await Me.reference.stopFirestoreObserver();
    log('[ClearData] [stopListeners]');
  }

  clearData() {
    Notifications.reference.clear();
    ContactUids.reference.clear();
    Contacts.reference.clear();
    Me.reference.clear();
  }
}