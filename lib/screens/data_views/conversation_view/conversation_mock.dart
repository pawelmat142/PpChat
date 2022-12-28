// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/state/states.dart';

class MessageMock extends StatelessWidget {
  final PpMessage mock;
  final PpUser contactUser;

  const MessageMock(this.mock, this.contactUser, {super.key});

  static const String TYPE_CLEAR = "TYPE_CLEAR";
  static const String TYPE_LOCK = "TYPE_LOCK";

  static const LOCK_ICON = Center(child: Icon(Icons.lock, color: WHITE_COLOR, size: 130));
  static const CLEAR_ICON = Center(child: Icon(Icons.speaker_notes_off, color: WHITE_COLOR, size: 130));
  static const DEFAULT_ICON = Center(child: Icon(Icons.question_mark_rounded, color: WHITE_COLOR, size: 130));

  _onTap() {
    final conversationService = getIt.get<ConversationService>();
    switch(mock.message) {
      case TYPE_LOCK: conversationService.onUnlock(contactUser.uid);
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            height: 200,
            width: 200,
            decoration: const BoxDecoration(
              color: PRIMARY_COLOR_LIGHTER,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                _iconWidget,
                Text(info, textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: WHITE_COLOR,
                    fontSize: 14
                )),
            ])
          ),
      ),
    );
  }

  Widget get _iconWidget {
    switch (mock.message) {
      case TYPE_CLEAR: return CLEAR_ICON;
      case TYPE_LOCK: return LOCK_ICON;
      default: return DEFAULT_ICON;
    }
  }

  String get info {
    switch (mock.message) {
      case TYPE_CLEAR: return conversationClearInfo;
      case TYPE_LOCK: return conversationLockInfo;
      default: return 'unknown';
    }
  }


  String get conversationClearInfo =>
      'Conversation cleared by ${mock.sender == States.getUid! ? 'You' : contactUser.nickname}';

  String get conversationLockInfo =>
      'Conversation locked by ${mock.sender == States.getUid! ? 'You' : contactUser.nickname}';
}

