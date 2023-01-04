import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:hive_flutter/adapters.dart';

class UnreadMessages extends StatelessWidget {
  const UnreadMessages({required this.contactUid, Key? key}) : super(key: key);

  final String contactUid;

  Conversations get conversations => Conversations.reference;

  //TODO: MessageCleaner instances should be in state of widget tree not deeper than contact tile

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(right: 20),

      child: FutureBuilder<Conversation>(
          future: conversations.openOrCreate(contactUid: contactUid),
          builder: (context, snapshot) {

            final conversation = snapshot.data;

            return conversation == null
              ? const SizedBox(height: 0)

              : ValueListenableBuilder<Box<PpMessage>>(
                  valueListenable: conversation.box.listenable(),

                  builder: (context, box, _) {
                    final unreadMessages = box.values.where((message) => !message.isRead);

                    if (unreadMessages.isEmpty) return const SizedBox(height: 0);

                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle
                      ),
                      height: 25,
                      width: 25,
                      child: AutoSizeText(unreadMessages.length.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: WHITE_COLOR,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )),
                    );
                  }
              );

      }),
    );
  }
}
