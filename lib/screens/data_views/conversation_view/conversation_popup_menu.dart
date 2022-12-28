import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';

class ConversationPopupMenu extends StatelessWidget {
  const ConversationPopupMenu({required this.conversation, Key? key}) : super(key: key);
  final Conversation conversation;

  @override
  Widget build(BuildContext context) {

    final conversationService = getIt.get<ConversationService>();

    return PopupMenuButton(iconSize: 30, itemBuilder: (BuildContext context) {

      return [

        PopupMenuItem(
          onTap: () => conversation.isLocked
            ? conversationService.onUnlock(conversation.contactUid)
            : conversationService.onLockConversation(conversation.contactUid),
          child: Row(
            children: [
              Icon(conversation.isLocked
                  ? Icons.lock_open_outlined
                  : Icons.lock,
                  color: PRIMARY_COLOR, size: 34),
              const SizedBox(width: 12),
              Text(conversation.isLocked
                  ? 'Unlock conversation'
                  : 'Lock conversation',
                  style: const TextStyle(color: PRIMARY_COLOR)),
        ])),

        PopupMenuItem(
          onTap: () => conversation.isLocked
            ? conversationService.onUnlock(conversation.contactUid)
            : conversationService.onLockConversation(conversation.contactUid),
          child: Row(
            children: const [
              Icon(Icons.speaker_notes_off, color: PRIMARY_COLOR, size: 34),
              SizedBox(width: 12),
              Text('Clear conversation', style: TextStyle(color: PRIMARY_COLOR)),
        ])),


        PopupMenuItem(
            onTap: _onDeleteContact,
            child: Row(
                children: const [
                  Icon(Icons.delete_forever, color: Colors.redAccent, size: 34),
                  SizedBox(width: 12),
                  Text('Delete contact', style: TextStyle(color: Colors.redAccent))
                ])),
        
      ];
    });
  }


  _onDeleteContact() async {
    final contactsService = getIt.get<ContactsService>();
    await contactsService.onDeleteContact(conversation.contactUid);
  }
}