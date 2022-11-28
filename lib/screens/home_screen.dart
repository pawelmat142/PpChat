import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notifications_info.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home_screen';


  @override
  Widget build(BuildContext context) {

    final authService = getIt.get<AuthenticationService>();
    final userService = getIt.get<PpUserService>();

    return Scaffold(

      appBar: AppBar(title: Text('HOME SCREEN - ${userService.nickname}')),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Column(
            children: [

              NotificationInfo(),

              PpButton(text: 'LOGOUT',
                onPressed: authService.logout,
              ),

              PpButton(text: 'DELETE ACCOUNT',
                onPressed: authService.onDeleteAccount,
              ),

              PpButton(text: 'CONTACTS',
                onPressed: () => Navigator.pushNamed(context, ContactsScreen.id),
              ),

          ]
        ),
      ),
    );

  }
}
