import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class TestScreen extends StatelessWidget {
  TestScreen({super.key});
  static const String id = 'test_screen';

  final userService = getIt.get<PpUserService>();
  bool logged = false;

  @override
  Widget build(BuildContext context) {

    String textFieldValue = '';
    return Scaffold(
      appBar: AppBar(title: const Text('TEST SCREEN')),
      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING.copyWith(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            TextField(
                onChanged: (value) => textFieldValue = value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'nickname',
                ),
            ),

            PpButton(text: 'get by nickname',
              onPressed: () async {
                final user = await userService.findByNickname(textFieldValue);
                if (user != null) {
                  print(user.nickname);
                  print(user.role);
                } else {
                  print('didnt find');
                }
              }
            ),

            PpButton(text: 'create',
              onPressed: () async {
                userService.createNewUser(nickname: textFieldValue);
              }
            ),

            PpButton(text: 'delete my acc',
              onPressed: () async {
                userService.deleteUserDocument();
              }
            ),

          ],
        ),
      ),
    );
  }
}

