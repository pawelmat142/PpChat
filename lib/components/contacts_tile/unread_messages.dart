import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:hive_flutter/adapters.dart';

class UnreadMessages extends StatefulWidget {
  const UnreadMessages({required this.contactUid, super.key});

  final String contactUid;


  @override
  State<UnreadMessages> createState() => _UnreadMessagesState();
}

class _UnreadMessagesState extends State<UnreadMessages> {
  Conversations get conversations => Conversations.reference;

  late Conversation conversation;

  bool isReady = false;

  late Future future;


  @override
  void initState() {
    super.initState();
    tryBuild();
  }

  tryBuild() {
    Future.delayed(const Duration(milliseconds: 500), () {
      final conversation = conversations.getByUid(widget.contactUid);
      if (conversation != null && conversation.isOpen && !isReady) {
        setState(() {
          this.conversation = conversation;
          isReady = true;
        });
      } else {
        tryBuild();
      }
    });
  }

  @override
  void dispose() {
    isReady = true; //to prevent triggering tryBuild anymore;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(right: 20),

      child: !isReady ? const SizedBox(height: 0) :

      ValueListenableBuilder<Box<PpMessage>>(
          valueListenable: conversation.box!.listenable(),

          builder: (context, box, _) {

            if (!box.isOpen) return const SizedBox(height: 0);
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
      ),

    );
  }
}
