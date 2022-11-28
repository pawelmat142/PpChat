import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/message_bubble.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({required this.receiver ,super.key});
  final String receiver;


  static navigate(String receiver) {
    Navigator.push(
      NavigationService.context,
      MaterialPageRoute(builder: (context) => ConversationView(receiver: receiver)),
    );
  }

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {

  List<MessageBubble> bubbles = [
    MessageBubble(message: 'one', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
    MessageBubble(message: 'two', my: false),
    MessageBubble(message: 'three', my: false),
    MessageBubble(message: 'four', my: true),
    MessageBubble(message: 'five', my: true),
  ];

  final _msgInputCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('${widget.receiver} - chat')),

      body: SafeArea(
        child: Column(
            children: [

              Expanded(child: ListView(
                reverse: true,
                padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
                children: bubbles.reversed.toList(),
              )),

              //MESSAGE TEXT INPUT
              Container(
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: PRIMARY_COLOR_DARKER, width: 2.0))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _msgInputCtrl,
                        // onChanged: (value) => _msgInputCtrl.value.text = value,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          hintText: 'Type your message here...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        //TODO: Implement send functionality
                        // _msgInputCtrl.clear();
                      },
                      child: const Text('Send', style: TextStyle(
                        color: PRIMARY_COLOR_DARKER,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      )),
                    ),
                  ],
                ),
              ),

            ],
        ),
      ),

    );
  }

}
