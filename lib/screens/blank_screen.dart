import 'package:flutter/material.dart';

import 'home_screen.dart';

class BlankScreen extends StatelessWidget {
  const BlankScreen({Key? key}) : super(key: key);
  static const String id = 'blank_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: TextButton(
          onPressed: () => Navigator.pushNamed(context, HomeScreen.id),
          child: const Text('GO TO HOME SCREEN'),
        ),
      ),
    );
  }
}
