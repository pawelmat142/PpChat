import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';

class AuthenticationService {

  final _fireAuth = FirebaseAuth.instance;
  final _popup = getIt.get<Popup>();

  get context => NavigationService.context;


  void register({required String login, required String password}) async {
    try {
      await _fireAuth.createUserWithEmailAndPassword(email: _toEmail(login), password: password);

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
      await _fireAuth.signInWithEmailAndPassword(email: _toEmail(login), password: password);

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

  static const String _firebaseEmailSuffix = '@no.email';
  String _toEmail(String login) => login + _firebaseEmailSuffix;
  String _toLogin(String email) => email.replaceAll(_firebaseEmailSuffix, '');
}