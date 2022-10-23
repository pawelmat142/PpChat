import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';

class AuthenticationService {

  final _fireAuth = FirebaseAuth.instance;
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();

  get context => NavigationService.context;

  bool logged = false;

  AuthenticationService() {
    _fireAuth.idTokenChanges().listen((user) async {
      user == null ? _logout() : _login();
      _firstUserListen = false;
    });
  }

  void register({required String login, required String password}) async {
    try {
      _spinner.start();
      _registerInProgress = true;
      await _fireAuth.createUserWithEmailAndPassword(email: _toEmail(login), password: password);
      await _fireAuth.signOut();
      _registerInProgress = false;
      _spinner.stop();

      _popup.show('Registration successful!',
        text: 'You can now log in.',
        enableOkButton: true,
        defaultAction: () => Navigator.pop(context, LoginFormScreen.id)
      );
    }
    catch (error) {
      _registerInProgress = false;
      if (error.toString().contains('email-already-in-use')) {
        _popup.show('Login already in use!', error: true);
        _spinner.stop();
        return;
      }
      _errorPopup();
    }
  }

  void login({required String login, required String password}) async {
    try {
      _spinner.start();
      await _fireAuth.signInWithEmailAndPassword(email: _toEmail(login), password: password);
      _spinner.stop();
    }
    catch (error) {
      _spinner.stop();
      await _popup.show('Wrong credentials!',
        text: 'Please try again.',
        error: true,
        enableNavigateBack: true
      );
    }
  }

  void logout() async {
    try {
      _spinner.start();
      await _fireAuth.signOut();
    }
    catch (error) {
      _errorPopup();
    }
  }


  bool _firstUserListen = true;
  bool _registerInProgress = false;

  void _login() async {
    if (!_registerInProgress) {
      _spinner.stop();
      logged = true;
      await Navigator.pushNamed(context, HomeScreen.id);
    }
  }

  void _logout() async {
    if (!_firstUserListen && !_registerInProgress) {
      _spinner.stop();
      logged = false;
      Navigator.pop(context, LoginFormScreen.id);
      await _popup.show('You are logged out!');
    }
  }

  void _errorPopup() {
    _spinner.stop();
    Navigator.pop(context, BlankScreen.id);
    _popup.show('Something went wrong!', error: true);
  }

  static const String _firebaseEmailSuffix = '@no.email';
  String _toEmail(String login) => login + _firebaseEmailSuffix;
  String _toLogin(String email) => email.replaceAll(_firebaseEmailSuffix, '');
}