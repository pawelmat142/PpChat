import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';

class AuthenticationService {
  final _fireAuth = FirebaseAuth.instance;
  final _userService = getIt.get<PpUserService>();
  final _notificationService = getIt.get<PpNotificationService>();
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();

  get context => NavigationService.context;

  bool _firstUserListen = true;
  bool _registerInProgress = false;

  AuthenticationService() {
    _fireAuth.idTokenChanges().listen((user) async {
      if (user == null) {
        _logoutResult();
      } else if (_firstUserListen) {
        _loginResult();
      }
      _firstUserListen = false;
    });
  }

  void register({required String nickname, required String password}) async {
    try {
      _spinner.start();
      _registerInProgress = true;
      await _fireAuth.createUserWithEmailAndPassword(email: _toEmail(nickname), password: password);
      await _userService.createNewUser(nickname: nickname);
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
      _spinner.stop();
      if (error.toString().contains('email-already-in-use')) {
        _popup.show('Nickname already in use!', error: true);
        return;
      }
      _errorPopup();
    }
  }

  //when user login by form
  void login({required String nickname, required String password}) async {
    try {
      _spinner.start();
      await _fireAuth.signInWithEmailAndPassword(email: _toEmail(nickname), password: password);
      await _loginServices();
      _spinner.stop();
      await Navigator.pushNamed(context, HomeScreen.id);
    }
    catch (error) {
      if (_fireAuth.currentUser != null) await _fireAuth.signOut();
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
      await _logoutServices();
      await _fireAuth.signOut();
    }
    catch (error) {
      _errorPopup();
    }
  }

  void deleteAccount() async {
    try {
      _spinner.start();
      await _userService.deleteUserDocument();
      //TODO: send information about deleted account - fire auth acc needs to be deleted manually
      await _fireAuth.signOut();
      _spinner.stop();
    }
    catch (error) {
      _errorPopup();
    }
  }

  //when user is already logged and start app
  void _loginResult() async {
    if (_firstUserListen) _loginServices();
    if (!_registerInProgress) {
      _spinner.stop();
      await Navigator.pushNamed(context, HomeScreen.id);
    }
  }

  void _logoutResult() async {
    if (!_firstUserListen && !_registerInProgress) {
      await _logoutServices();
      _spinner.stop();
      await _popup.show('You are logged out!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  _loginServices() async {
    await _userService.login(nickname: _toNickname(_fireAuth.currentUser!.email!));
    _notificationService.login();
  }

  _logoutServices() async {
    await _userService.logout();
    _notificationService.logout();
  }

  void _errorPopup() {
    _spinner.stop();
    Navigator.pop(context, BlankScreen.id);
    _popup.show('Something went wrong!', error: true);
  }

  static const String _firebaseEmailSuffix = '@no.email';
  String _toEmail(String login) => login + _firebaseEmailSuffix;
  String _toNickname(String email) => email.replaceAll(_firebaseEmailSuffix, '');
}