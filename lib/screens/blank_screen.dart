import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_service.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/forms/register_form_screen.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/services/app_service.dart';
import 'package:flutter_chat_app/services/awesome_notifications/notification_controller.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

import '../services/authentication_service.dart';

class BlankScreen extends StatefulWidget {
  static const String id = 'blank_screen';

  const BlankScreen({super.key});

  @override
  State<BlankScreen> createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {

  final appService = getIt.get<AppService>();
  final logService = getIt.get<LogService>();
  log(String txt) => logService.log(txt);

  late StreamSubscription<FGBGType> subscription;


  @override
  void initState() {
    super.initState();
    NotificationController.initListeners();
    ContactsScreen.navigate(context);

    subscription = FGBGEvents.instance.stream.listen((event) {
      appService.isAppInBackground = event == FGBGType.background;
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Center(
          child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Image.asset('assets/images/icon.png'),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text('PpChat', style: TextStyle(
                        fontFamily: AvatarService.avatarFont,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      )),
                    ),

                    PpButton(
                        text: 'Login',
                        onPressed: () => Navigator.pushNamed(context, LoginFormScreen.id),
                    ),

                    PpButton(
                      text: 'Register',
                      onPressed: () => Navigator.pushNamed(context, RegisterFormScreen.id),
                      color: PRIMARY_COLOR_DARKER,
                    ),

                    // The buttons are used to simplify the login process for testing purposes.
                    // PpButton(text: 'log aaaaaa',
                    //   onPressed: () {
                    //     final authService = getIt.get<AuthenticationService>();
                    //     authService.login(nickname: 'aaaaaa', password: 'aaaaaa');
                    //   },
                    // ),
                    //
                    // PpButton(
                    //   text: 'log bbbbbb',
                    //   onPressed: () {
                    //     final authService = getIt.get<AuthenticationService>();
                    //     authService.login(nickname: 'bbbbbb', password: 'bbbbbb');
                    //   },
                    // ),
                    //
                    // PpButton(
                    //   text: 'log cccccc',
                    //   onPressed: () {
                    //     final authService = getIt.get<AuthenticationService>();
                    //     authService.login(nickname: 'cccccc', password: 'cccccc');
                    //   },
                    // ),

                  ]
                ),
          ),
        ),
      ),
    );
  }

}