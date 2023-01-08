import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/process/logout_process.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/services/log_service.dart';

class AuthenticationService {
  final _fireAuth = FirebaseAuth.instance;
  final _userService = getIt.get<PpUserService>();
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();
  final logService = getIt.get<LogService>();

  log(String txt) => logService.log(txt);
  logError(String txt) => logService.error(txt);


  get context => NavigationService.context;

  bool _isRegisterInProgress = false;
  bool _isDeletingAccount = false;

  String get getUid => Uid.get!;

  void onLogin({required String nickname, required String password}) async {
    try {
      log('[START] Login by form process');
      _spinner.start();
      final userCredential = await _fireAuth.signInWithEmailAndPassword(email: _toEmail(nickname), password: password);
      _spinner.stop();

      if (userCredential.user != null && !_isRegisterInProgress) {
        log('[FireAuth listener] login');
        Navigator.pushNamed(context, ContactsScreen.id);
        // onInit HomeScreen triggers LoginProcess
      }
      else {
        _popup.sww(text: 'login by form: user missing');
      }
      log('[STOP] Login by form process');
    }
    on FirebaseAuthException {
      _spinner.stop();
      if (_fireAuth.currentUser != null) await _fireAuth.signOut();
      await _popup.show('Wrong credentials!',
          text: 'Please try again.',
          error: true,
          enableNavigateBack: true
      );
    } catch (error) {
      _spinner.stop();
      logService.errorHandler(error);
    }
  }

  void onLogout() async {
    try {
      _spinner.start();
      final process = LogoutProcess();
      await process.process();
      await signOut();
      _spinner.stop();
      _logoutResult(skipSignOut: true);
    }
    catch (error) {
      logService.errorHandler(error);
      _errorPopup();
    }
  }

  signOut() async {
    if (_fireAuth.currentUser?.uid != null) {
      await _fireAuth.signOut();
    }
  }

  void _logoutResult({bool skipSignOut = false}) async {
    if (!_isRegisterInProgress && !_isDeletingAccount) {
      if (!skipSignOut) await signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
      PpSnackBar.logout();
    }
    _isDeletingAccount = false;
  }


  void register({required String nickname, required String password}) async {
    try {
      _spinner.start();
      _isRegisterInProgress = true;
      await _fireAuth.createUserWithEmailAndPassword(email: _toEmail(nickname), password: password);
      await _userService.createNewUser(nickname: nickname);
      await _fireAuth.signOut();
      _isRegisterInProgress = false;
      _spinner.stop();

      _popup.show('Registration successful!',
        text: 'You can now log in.',
        enableOkButton: true,
        defaultAction: () => Navigator.pop(context, LoginFormScreen.id)
      );
    } on FirebaseAuthException {
      _nicknameInUse();
    } catch (error) {
      _isRegisterInProgress = false;
      logService.errorHandler(error);
    }
  }

  _nicknameInUse () {
    _spinner.stop();
    _isRegisterInProgress = false;
    _popup.show('Nickname already in use!', error: true);
  }

  void _errorPopup() {
    _spinner.stop();
    Navigator.pop(context, BlankScreen.id);
    _popup.show('Something went wrong!', error: true);
  }

  static const String _firebaseEmailSuffix = '@no.email';
  static String _toEmail(String login) => login + _firebaseEmailSuffix;
  static String _toNickname(String email) => email.replaceAll(_firebaseEmailSuffix, '');
  static String get nickname => _toNickname(FirebaseAuth.instance.currentUser!.email!);
}