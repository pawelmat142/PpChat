import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';

class AuthenticationService {

  final _popup = getIt.get<Popup>();

  get context => NavigationService.context;

  void register({required String login, required String password}) async {
    try {
      _popup.show('Registration successful!',
        text: 'You can now log in.',
        enableOkButton: true,
        defaultAction: () => Navigator.pop(context, LoginFormScreen.id)
      );
    }
    catch (error) {
      _errorPopup();
    }
  }

  void login({required String login, required String password}) async {
    try {
      _popup.show('You are logged in!',
        defaultAction: () => Navigator.pushNamed(context, HomeScreen.id),
      );
    }
    catch (error) {
      _errorPopup();
    }
  }

  void logout() async {
    try {

    }
    catch (error) {
      _errorPopup();
    }
  }

  void _errorPopup() {
    Navigator.pop(context, BlankScreen.id);
    _popup.show('Something went wrong!', error: true);
  }
}