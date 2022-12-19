import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';

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

        PopupMenuItem(onTap: () {
          _conversationService.resolveUnresolvedMessages();
        },
          child: const Text('test'),
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