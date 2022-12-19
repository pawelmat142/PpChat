// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/state/states.dart';

class ConversationMock extends StatelessWidget {
  final PpMessage mock;
  final PpUser contactUser;

  const ConversationMock(this.mock, this.contactUser, {super.key});

  static const String IS_MOCK_RECEIVER = "IS_MOCK_RECEIVER";
  static const String CONVERSATION_MOCK_TYPE_CLEAR = "CONVERSATION_MOCK_TYPE_CLEAR";
  static const String CONVERSATION_MOCK_TYPE_LOCK = "CONVERSATION_MOCK_TYPE_LOCK";

  static const LOCK_ICON = Center(child: Icon(Icons.lock, color: WHITE_COLOR, size: 130));
  static const CLEAR_ICON = Center(child: Icon(Icons.speaker_notes_off, color: WHITE_COLOR, size: 130));

  _onTap() {
    if (kDebugMode) {
      print('on tap');
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
                CLEAR_ICON,
                Text(conversationClearInfo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: WHITE_COLOR,
                    fontSize: 14
                )),
            ])
          ),
      ),
    );
  }

  String get conversationClearInfo =>
      'Conversation cleared by ${mock.sender == States.getUid! ? 'You' : contactUser.nickname}';
}

