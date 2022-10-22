import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/getIt.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/forms/register_form_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';

void main() async {
  await initGetIt();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter chat app',
      theme: ThemeData.light(),
      initialRoute: BlankScreen.id,
      routes: {
        BlankScreen.id: (context) => const BlankScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        LoginFormScreen.id: (context) => LoginFormScreen(),
        RegisterFormScreen.id: (context) => RegisterFormScreen(),
      },
    );
  }
}