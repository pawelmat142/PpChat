import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/message_bubble.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';

class ConversationView extends StatefulWidget {
  ConversationView({required this.receiver ,super.key});
  final String receiver;

  final _conversationService = getIt.get<ConversationService>();
  final _userService = getIt.get<PpUserService>();


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

  StreamSubscription? _firestoreListener;

  List<PpMessage> msgs = [];
  List<MessageBubble> bubbles = [];

  final _messageInputController = TextEditingController();
  String get message => _messageInputController.value.text;

  _onSend() async {
    if (message.isEmpty) return;
    // TODO: show spinning / loading / block button, textfield
    final msg = PpMessage.create(
        message: message,
        sender: widget._userService.nickname,
        receiver: widget.receiver
    );
    await widget._conversationService.onSendMessage(msg);
    _messageInputController.clear();
    msgs.add(msg);
    _resetBubbles();
  }

  _newMessageReceived(PpMessage message) {
    msgs.add(message);
    _resetBubbles();
  }

  _resetBubbles() {
    setState(() {
      bubbles = msgs.map((m) => MessageBubble(message: m.message, my: _isMyMsg(m))).toList();
    });
  }

  _isMyMsg(PpMessage message) {
    return message.sender == widget._userService.nickname;
  }

  @override
  void initState() {
    super.initState();
    print('init');
    _firestoreListener = widget._conversationService.messagesCollectionRef.snapshots().listen((event) {
      for (var change in event.docChanges) {
        print('event.docChanges.length: ${event.docChanges.length}');
        switch (change.type) {
          case DocumentChangeType.added:
            _newMessageReceived(PpMessage.fromDB(change.doc));
            break;
        }
      }

    });
  }

  @override
  void dispose() {
    print('dispose');
    _firestoreListener!.cancel();
    super.dispose();
  }

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

            ],
        ),
      ),

    );
  }

}
