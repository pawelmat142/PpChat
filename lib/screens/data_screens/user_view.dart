import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_screens/data_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class UserView extends DataView {
  const UserView({required super.interface,  super.key});

  static navigate(PpUser user) {
    Navigator.push(
        NavigationService.context,
        MaterialPageRoute(builder: (context) => UserView(interface: DataViewInterface(
          title: 'CONTACT VIEW',
          textOne: user.nickname,
          textTwo: user.logged ? 'Active' : 'Inactive',
          buttons: [

            PpButton(text: 'message', onPressed: () {
            //  TODO: navigate to message
            }),

            PpButton(text: 'delete', color: Colors.red, onPressed: (){
            //  TODO: delete contact feature
            })
          ]
        )))
    );
  }

}