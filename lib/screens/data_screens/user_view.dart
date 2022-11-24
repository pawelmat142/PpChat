import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_screens/data_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';

class UserView extends DataView {
  const UserView({required super.interface,  super.key});

  static navigate(PpUser user) async {
    final contactsService = getIt.get<ContactsService>();
    final popup = getIt.get<Popup>();

    await Navigator.push(
        NavigationService.context,
        MaterialPageRoute(builder: (context) => UserView(interface: DataViewInterface(
          title: 'CONTACT VIEW',
          textOne: user.nickname,
          textTwo: user.logged ? 'Active' : 'Inactive',
          buttons: [

            PpButton(text: 'message', onPressed: () {
            //  TODO: navigate to message
            }),

            PpButton(text: 'delete', color: Colors.red, onPressed: () {
              popup.show('Are you shure?', buttons: [PopupButton('Delete', onPressed: () async {
                await contactsService.deleteContactForSender(user.nickname);
                Navigator.pop(NavigationService.context);
              })]);

            })
          ]
        )))
    );
  }

}