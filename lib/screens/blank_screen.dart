import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

import 'forms/login_form_screen.dart';
import 'home_screen.dart';

class BlankScreen extends StatelessWidget {
  const BlankScreen({Key? key}) : super(key: key);
  static const String id = 'blank_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Center(
          child: PpButton(
            onPressed: () => Navigator.pushNamed(context, LoginFormScreen.id),
            text: 'GO TO LOGIN SCREEN',
          ),
        ),
      ),
    );
  }
}
