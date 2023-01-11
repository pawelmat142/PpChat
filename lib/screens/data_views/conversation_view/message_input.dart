import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:flutter_chat_app/constants/styles.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({required this.conversation, required, Key? key}) : super(key: key);
  final Conversation conversation;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {

  final _messageInputController = TextEditingController();
  String get message => _messageInputController.value.text;

  bool _ready = true;
  pendingOn() => setState(() => _ready = false);
  pendingOff() => setState(() =>_ready = true);


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
    pendingOn();

    await widget.conversation.sendMessage(message);
    _messageInputController.clear();

    pendingOff();
  }

}
