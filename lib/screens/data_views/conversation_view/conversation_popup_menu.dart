import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_service.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_settings_view.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';

class ConversationPopupMenu extends StatelessWidget {
  const ConversationPopupMenu({required this.conversation, Key? key}) : super(key: key);
  final Conversation conversation;

  PpUser get contactUser => Contacts.reference.getByUid(conversation.contactUid)!;

  @override
  Widget build(BuildContext context) {

    final conversationService = getIt.get<ConversationService>();


    return PopupMenuButton(
        iconSize: 50,
        icon: AvatarWidget(
            size: 50,
            uid: conversation.contactUid,
            model: contactUser.avatar,
        ),
        itemBuilder: (BuildContext context) {
      return [

        PopupMenuItem(
          onTap: () => UserView.popAndNavigate(user: contactUser, delay: 10),
          child: Row(
            children: [
              AvatarWidget(
                  uid: conversation.contactUid,
                  model: contactUser.avatar,
                size: 34,
              ),
              // Icon(Icons.speaker_notes_off, color: Colors.deepOrangeAccent, size: 34),
              const SizedBox(width: 12),
              Text('User view', style: TextStyle(color: AvatarService.getColor(contactUser.avatar.color))),
        ])),

        PopupMenuItem(
          onTap: () => conversation.isLocked
            ? conversationService.onUnlock(conversation.contactUid)
            : conversationService.onClearConversation(conversation.contactUid),
          child: Row(
            children: const [
              Icon(Icons.speaker_notes_off, color: Colors.deepOrangeAccent, size: 34),
              SizedBox(width: 12),
              Text('Clear conversation', style: TextStyle(color: Colors.deepOrangeAccent)),
        ])),

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
            onTap: _onSettings,
            child: Row(
                children: const [
                  Icon(Icons.settings, color: Colors.green, size: 34),
                  SizedBox(width: 12),
                  Text('Settings', style: TextStyle(color: Colors.green))
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

  _onSettings() {
    Future.delayed(const Duration(milliseconds: 0), () {
      ConversationSettingsView.navigate(conversation.contactUid);
    });
  }
}