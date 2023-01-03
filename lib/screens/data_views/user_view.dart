import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_views/data_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';

class UserView extends DataView {
  const UserView({required super.interface,  super.key});

  static navigate(PpUser user) async {
    final contactsService = getIt.get<ContactsService>();

    await Navigator.push(
        NavigationService.context,
        MaterialPageRoute(builder: (context) => UserView(interface: DataViewInterface(
          title: 'CONTACT VIEW',
          textOne: user.nickname,
          textTwo: user.logged ? 'Active' : 'Inactive',
          buttons: [

            PpButton(text: 'message', onPressed: () {
              final conversationService = getIt.get<ConversationService>();
              if (contactsService.contactExists(user.uid)) {
                conversationService.navigateToConversationView(user);
              } else {
                PpSnackBar.contactNotExists();
              }
            }),

            PpButton(text: 'delete', color: Colors.red, onPressed: () async {
              if (contactsService.contactExists(user.uid)) {
                await contactsService.onDeleteContact(user.uid);
              } else {
                PpSnackBar.contactNotExists();
              }
            })
          ]
        )))
    );
  }

}