import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/services/log_service.dart';

class AuthenticationService {
  final _fireAuth = FirebaseAuth.instance;
  final _userService = getIt.get<PpUserService>();
  final _contactsService = getIt.get<ContactsService>();
  final _notificationService = getIt.get<PpNotificationService>();
  final _conversationsService = getIt.get<ConversationService>();
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();
  final logService = getIt.get<LogService>();

  log(String txt) => logService.log(txt);
  logError(String txt) => logService.error(txt);


  get context => NavigationService.context;

  bool _isFirstUserListen = true;
  bool _isRegisterInProgress = false;
  bool _isDeletingAccount = false;

  AuthenticationService() {
    _fireAuth.idTokenChanges().listen((user) async {
      if (user == null) {
        log('[FireAuth] logout');
        _logoutResult(skipSignOut: true);
      } else if (_isFirstUserListen) {
        _loginResult();
      }
      _isFirstUserListen = false;
    });
  }

  String get getUid => _userService.getUid;

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

  //when user login by form
  void login({required String nickname, required String password}) async {
    try {
      log('[START] Login by form process');
      _spinner.start();
      await _fireAuth.signInWithEmailAndPassword(email: _toEmail(nickname), password: password);
      await _loginServices();
      log('[STOP] Login by form process');
      _spinner.stop();
      await Navigator.pushNamed(context, HomeScreen.id);
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

  void logout() async {
    try {
      _spinner.start();
      await logoutServices();
      await signOut();
    }
    catch (error) {
      logService.errorHandler(error);
      _errorPopup();
    }
  }

  signOut() async {
      await _fireAuth.signOut();
  }


  //when user is already logged and start app
  void _loginResult() async {
    if (_isFirstUserListen) _loginServices();
    if (!_isRegisterInProgress) {
      _spinner.stop();
      await Navigator.pushNamed(context, HomeScreen.id);
    }
  }

  void _logoutResult({bool skipSignOut = false}) async {
    if (!_isFirstUserListen && !_isRegisterInProgress && !_isDeletingAccount) {
      await logoutServices(skipSignOut: skipSignOut);
      _spinner.stop();
      await _popup.show('You are logged out!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    _isDeletingAccount = false;
  }

  _loginServices() async {
    final currentNickname = nickname;
    States.login(nickname: currentNickname);
    logService.setContext(currentNickname);
  }

  logoutServices({bool skipSignOut = false}) async {
    log('[START] logout services');
    await _conversationsService.logout();
    await _contactsService.logout();
    _notificationService.logout();
    await _userService.logout();
    if (!skipSignOut) {
      await signOut();
    }
    log('[STOP] logout services');
    logService.setContext('log outed');
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