import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home_screen';


  @override
  Widget build(BuildContext context) {

    final authService = getIt.get<AuthenticationService>();

    return Scaffold(

      appBar: AppBar(
        title: const Text('HOME SCREEN'),
      ),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Column(
            children: [

              PpButton(text: 'LOGOUT',
                onPressed: authService.logout,
              ),

              PpButton(text: 'DELETE ACCOUNT',
                onPressed: authService.deleteAccount,
              ),

          ]
        ),
      ),
    );

  }
}
