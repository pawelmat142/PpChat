import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/dialogs/process/login_process.dart';
import 'package:flutter_chat_app/models/provider/contact_uids.dart';
import 'package:flutter_chat_app/models/provider/contacts.dart';
import 'package:flutter_chat_app/models/provider/notifications.dart';
import 'package:flutter_chat_app/models/provider/me.dart';

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

    LoginProcess();

    log('[InitData] [STOP]');
  }

}