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

            PpButton(text: 'create user',
              onPressed: () {
                userService.createNewUser(nickname: textFieldValue);
              }
            ),

            PpButton(text: 'get user snapshot',
              onPressed: () async {
                final result = await userService.userSnapshot;
                print(result);
                print(result.nickname);
              }
            ),

            PpButton(text: 'get user from service',
              onPressed: () {
                final result = userService.user;
                print(result);
                print(result.nickname);
              }
            ),

            PpButton(text: 'toggle logged - update',
              onPressed: () async {
                logged = !logged;
                await userService.setLogged(logged);
              }
            ),
          ],
        ),
      ),
    );
  }
}

