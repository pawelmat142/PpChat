import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({required this.contactUser, Key? key}) : super(key: key);
  final PpUser contactUser;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {

  final _conversationService = getIt.get<ConversationService>();

  final _messageInputController = TextEditingController();
  String get message => _messageInputController.value.text;

  bool _ready = true;

  //TODO: block chat feature

  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: PRIMARY_COLOR_DARKER, width: 2.0))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageInputController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  hintText: 'Type your message here...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black54),
              ),
            ),

            IconButton(
                iconSize: 40,
                onPressed: () {
                  if (_ready) _onSend();
                },
                icon: Icon(
                    _ready ? Icons.send_rounded : Icons.autorenew_rounded,
                    color: _ready ? PRIMARY_COLOR : Colors.grey
                )
            )

          ],
        ),
      );
  }

  _onSend() async {
    if (message.isEmpty) return;
    setState((){_ready = false;});

    await _conversationService.sendMessage(
        message: message,
        contactUser: widget.contactUser);

    _messageInputController.clear();
    setState((){_ready = true;});
  }


}
