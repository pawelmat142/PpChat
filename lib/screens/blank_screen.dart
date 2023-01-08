import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/forms/register_form_screen.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/services/uid.dart';

class BlankScreen extends StatelessWidget {
  const BlankScreen({Key? key}) : super(key: key);
  static const String id = 'blank_screen';

  @override
  Widget build(BuildContext context) {

    if (Uid.get != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, ContactsScreen.id);
      });
    }

    return Scaffold(

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              PpButton(
                  text: 'LOGIN',
                  onPressed: () => Navigator.pushNamed(context, LoginFormScreen.id),
              ),

              PpButton(
                  text: 'REGISTER',
                  onPressed: () => Navigator.pushNamed(context, RegisterFormScreen.id),
                  color: PRIMARY_COLOR_DARKER,
              ),

              PpButton(
                  text: 'log aaaaaa',
                  onPressed: () {
                    final authService = getIt.get<AuthenticationService>();
                    authService.onLogin(nickname: 'aaaaaa', password: 'aaaaaa');
                  },
              ),

              PpButton(
                  text: 'log bbbbbb',
                  onPressed: () {
                    final authService = getIt.get<AuthenticationService>();
                    authService.onLogin(nickname: 'bbbbbb', password: 'bbbbbb');
                  },
              ),

              PpButton(
                  text: 'log cccccc',
                  onPressed: () {
                    final authService = getIt.get<AuthenticationService>();
                    authService.onLogin(nickname: 'cccccc', password: 'cccccc');
                  },
              ),

            ]
          ),
        ),
      ),
    );
  }
}
