import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/message_bubble.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:hive_flutter/adapters.dart';

class ConversationView extends StatefulWidget {
  ConversationView({required this.contactNickname ,super.key});
  final String contactNickname;

  final _conversationService = getIt.get<ConversationService>();
  final _contactService = getIt.get<ContactsService>();
  final _userService = getIt.get<PpUserService>();
  final _spinner = getIt.get<PpSpinner>();
  final _popup = getIt.get<Popup>();


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

  Box<PpMessage>? _messagesBox;

  bool _ready = true;

  _onSend() async {
    if (message.isEmpty) return;
    setState((){_ready = false;});
    final msg = PpMessage.create(
        message: message,
        sender: widget._userService.nickname,
        receiver: widget.contactNickname
    );
    await widget._conversationService.onSendMessage(msg);
    _messageInputController.clear();
    setState((){_ready = true;});
  }

  _isMyMsg(PpMessage message) {
    return message.sender == widget._userService.nickname;
  }

  @override
  void initState() {
    _messagesBox = widget._conversationService.getConversationBox(widget.contactNickname);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
          title: Text('${widget.contactNickname} - chat'),
          actions: [_getPopupMenu()],
      ),

      body: SafeArea(
        child: Column(children: [

              //MESSAGES AREA

              Expanded(child: ValueListenableBuilder<Box<PpMessage>>(
                valueListenable: _messagesBox!.listenable(),
                builder: (context, box, _) {

                  return ListView(reverse: true,
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    children: box.values.map((m) {

                      return MessageBubble(message: m.message, my: _isMyMsg(m));

                    }).toList().reversed.toList(),
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

                    _getSendButton(),

                  ],
                ),
              ),

        ]),
      ),

    );
  }

  _getSendButton() {
    return IconButton(
        iconSize: 40,
        onPressed: () {
          if (_ready) _onSend();
        },
        icon: Icon(
            _ready ? Icons.send_rounded : Icons.autorenew_rounded,
            color: _ready ? PRIMARY_COLOR : Colors.grey
        )
    );
  }

  _getPopupMenu() => PopupMenuButton(
      iconSize: 30,
      itemBuilder: (BuildContext context) {
        return [

          PopupMenuItem(onTap: _onClearConversation,
            child: const Text('Clear conversation'),
          ),

          PopupMenuItem(onTap: () => widget._contactService.onDeleteContact(widget.contactNickname),
            child: const Text('Delete contact'),
          ),

          PopupMenuItem(onTap: () {},
            child: const Text('three'),
          ),

        ];
    }
  );

  _onClearConversation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    widget._popup.show('Are you sure?',
        text: 'Messages data will be lost also on the other side!',
        buttons: [PopupButton('Clear', onPressed: () async {
          widget._spinner.start();
          await widget._conversationService.clearConversation(widget.contactNickname);
          widget._spinner.stop();
    })]);
  }

}
