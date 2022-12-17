import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/message_bubble.dart';
import 'package:flutter_chat_app/components/message_input.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/state/conversation.dart';
import 'package:flutter_chat_app/state/conversations.dart';
import 'package:hive_flutter/adapters.dart';

class ConversationView extends StatelessWidget {
  ConversationView({super.key});
  static const id = 'conversation_view';

  final _userService = getIt.get<PpUserService>();
  final _conversationService = getIt.get<ConversationService>();

  static navigate(PpUser contact) {
    Navigator.pushNamed(
      NavigationService.context,
      ConversationView.id,
      arguments: contact
    );
  }


  Conversations get conversations => _conversationService.conversations;

  Conversation conversation(contactNickname) => _conversationService
      .conversations.getByNickname(contactNickname)!;


  _isMyMsg(PpMessage message) => message.sender == _userService.nickname;

  @override
  Widget build(BuildContext context) {

    final contactUser = ModalRoute.of(context)!.settings.arguments as PpUser;

    return Scaffold(

        appBar: AppBar(
          title: Text('${contactUser.nickname} - chat'),
          actions: [PopupMenu(contactUser: contactUser)],
        ),

        body: SafeArea(
          child: Column(children: [

          //MESSAGES AREA

            Expanded(child: ValueListenableBuilder<Box<PpMessage>>(
              valueListenable: conversation(contactUser.nickname).box.listenable(),
              builder: (context, box, _) {

                // if (_isConversationClearedByContact) {
                //   return _chatClearedWidget();
                // }

                return ListView(reverse: true,
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  children: box.values.map((m) {

                    return MessageBubble(message: m.message, my: _isMyMsg(m));

                  }).toList().reversed.toList(),
                );
            })),


            MessageInput(contactUser: contactUser),

          ]),
        ),
    );
  }

}

class PopupMenu extends StatelessWidget {
  PopupMenu({required this.contactUser, Key? key}) : super(key: key);

  final PpUser contactUser;

  final _conversationService = getIt.get<ConversationService>();
  final _contactsService = getIt.get<ContactsService>();
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();


  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(iconSize: 30, itemBuilder: (BuildContext context) {

      return [
        PopupMenuItem(onTap: _onClearConversation,
          child: const Text('Clear conversation'),
        ),

        PopupMenuItem(onTap: _onDeleteContact,
          child: const Text('Delete contact'),
        ),

        PopupMenuItem(onTap: () {},
          child: const Text('three'),
        ),

      ];
    });
  }


  _onClearConversation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _popup.show('Are you sure?',
        text: 'Messages data will be lost also on the other side!',
        buttons: [PopupButton('Clear', onPressed: () async {
          _spinner.start();
          await _conversationService.clearConversation(contactUser);
          _spinner.stop();
    })]);
  }

  _onDeleteContact() async {
    await _contactsService.onDeleteContact(contactUser);
  }

//
//   TODO: _chatClearedWidget() {
//     _isConversationClearedByContact = false;
//     return Center(child: Text('Chat cleared by ${widget.contactNickname}', style: const TextStyle(fontSize: 18)));
//   }
}