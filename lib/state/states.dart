import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/state/contact_nicknames.dart';
import 'package:flutter_chat_app/state/contacts.dart';
import 'package:flutter_chat_app/dialogs/process/login_process.dart';
import 'package:flutter_chat_app/state/conversations.dart';
import 'package:flutter_chat_app/state/me.dart';
import 'package:flutter_chat_app/state/notifications.dart';

class States {

  static String get getUid => FirebaseAuth.instance.currentUser == null
      ? _handleNoCurrentUser()
      : FirebaseAuth.instance.currentUser!.uid;

  static _handleNoCurrentUser() {
    //todo: handle no current user / clear state data
    NavigationService.popToBlank();
    if (kDebugMode) {
      print('NO CURRENT USER!');
    }
  }

  final contactNicknames = ContactNicknames();

  /// User object representing signed in user - stored in firestore
  final me = Me();

  String get nickname => me.nickname;

  /// User objects representing contacts - stored in firestore
  final contacts = Contacts();

  /// Conversations object stores Conversation objects what stores hive box representing single conversation
  /// based on Messages subcollection listener
  final conversations = Conversations();

  /// PpNotifications objects - based on NOTIFICATIONS subcollection listener
  final notifications = Notifications();


  static void login({required String nickname}) {
    LoginProcess(nickname: nickname);
  }


  clearStateData() {
    contacts.clear();
    me.clear();
  }


}