import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/message_bubble.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:hive_flutter/adapters.dart';

class ConversationView extends StatefulWidget {
  ConversationView({required this.contactNickname ,super.key});
  final String contactNickname;

  final _conversationService = getIt.get<ConversationService>();
  final _userService = getIt.get<PpUserService>();


  static navigate(String contactNickname) {
    Navigator.push(
      NavigationService.context,
      MaterialPageRoute(builder: (context) => ConversationView(contactNickname: contactNickname)),
    );
  }

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {

  final _messageInputController = TextEditingController();
  String get message => _messageInputController.value.text;

  Box<PpMessage>? box;

  _onSend() async {
    if (message.isEmpty) return;
    // TODO: show spinning / loading / block button, textfield
    final msg = PpMessage.create(
        message: message,
        sender: widget._userService.nickname,
        receiver: widget.contactNickname
    );
    await widget._conversationService.onSendMessage(msg);
    _messageInputController.clear();
  }

  _isMyMsg(PpMessage message) {
    return message.sender == widget._userService.nickname;
  }

  @override
  void initState() {
    box = widget._conversationService.getConversationBox(widget.contactNickname);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('${widget.contactNickname} - chat')),

      body: SafeArea(
        child: Column(children: [

              //MESSAGES AREA

              Expanded(child: ValueListenableBuilder<Box<PpMessage>>(
                valueListenable: box!.listenable(),
                builder: (context, box, _) {

                  final bubbles = box.values
                      .map((m) => MessageBubble(message: m.message, my: _isMyMsg(m))
                  ).toList().reversed.toList();

                  return ListView(reverse: true,
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    children: bubbles,
                  );
                },
              )),


              //MESSAGE TEXT INPUT

              Container(
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
                    TextButton(
                      onPressed: _onSend,
                      child: const Text('Send', style: TextStyle(
                        color: PRIMARY_COLOR_DARKER,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      )),
                    ),

                  ],
                ),
              ),

        ]),
      ),

    );
  }

}
