import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/provider/contact_uids.dart';
import 'package:flutter_chat_app/models/provider/contacts.dart';
import 'package:flutter_chat_app/models/provider/me.dart';

class ClearData extends LogProcess {
  final BuildContext context;

  ClearData(this.context);

  process() async {
    log('[ClearData] [START]');
    await stopListeners();
    clearData();
    log('[ClearData] [STOP]');
  }

  stopListeners() async {
    await Contacts.reference.stopContactUidsListener();
    await ContactUids.reference.stopFirestoreObserver();
    await Contacts.reference.stopFirestoreObserver();
    await Me.reference.stopFirestoreObserver();
    log('[ClearData] [stopListeners]');
  }

  clearData() {
    ContactUids.reference.clear();
    Contacts.reference.clear();
    Me.reference.clear();
  }
}