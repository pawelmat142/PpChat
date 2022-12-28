import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/provider/contact_uids.dart';
import 'package:flutter_chat_app/models/provider/contacts.dart';
import 'package:flutter_chat_app/models/provider/me.dart';
import 'package:provider/provider.dart';

class InitData extends LogProcess {
  final BuildContext context;

  InitData(this.context) {
    start();
  }

  Me get me => Provider.of<Me>(context, listen: false);
  ContactUids get contactUids => Provider.of<ContactUids>(context, listen: false);
  Contacts get contacts => Provider.of<Contacts>(context, listen: false);

  start() async {
    log('[InitData] [START]');

    await me.startFirestoreObserver();
    log('[InitData] [Me] initialized');

    await contactUids.startFirestoreObserver();
    log('[InitData] [ContactUids] initialized');

    await contacts.reload(contactUids.get);
    log('[InitData] [Contacts] initialized');

    contactUids.addListener(() {
      log('[InitData] [Contacts] reloading');
      contacts.reload(contactUids.get);
    });
    log('[InitData] [Contacts] listener added');





    log('[InitData] [STOP]');
  }

}