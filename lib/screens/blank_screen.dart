import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/process/delete_account_process.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';

class BlankScreen extends StatelessWidget {
  const BlankScreen({Key? key}) : super(key: key);
  static const String id = 'blank_screen';

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              PpButton(
                  text: 'GO TO LOGIN SCREEN',
                  onPressed: () => Navigator.pushNamed(context, LoginFormScreen.id),
              ),

              PpButton(
                  text: 'GO TO HOME SCREEN',
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.pushNamed(context, HomeScreen.id);
                    }
                  },
              ),

            ]
          ),
        ),
      ),
    );
  }
}
