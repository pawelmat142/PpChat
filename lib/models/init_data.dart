import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/me.dart';
import 'package:provider/provider.dart';

class InitData extends LogProcess {
  final BuildContext context;

  InitData(this.context) {
    start();
  }

  Me get me => Provider.of<Me>(context, listen: false);

  start() async {
    log('[InitData] [START]');

    final meUser = await me.start();
    log('[InitData] [Me] initialized');

    log('[InitData] [STOP]');
  }

}