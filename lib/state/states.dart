import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/state/contact_uids.dart';
import 'package:flutter_chat_app/state/contacts.dart';
import 'package:flutter_chat_app/dialogs/process/login_process.dart';
import 'package:flutter_chat_app/state/conversations.dart';
import 'package:flutter_chat_app/state/me.dart';
import 'package:flutter_chat_app/state/notifications.dart';

class States {

  /// PpUser object representing signed in user - stored in firestore
  final me = Me();

  /// list of contacts fireAuth uid
  final contactUids = ContactUids();

  /// PpUser objects representing contacts - stored in firestore
  final contacts = Contacts();

  /// Conversations object stores Conversation objects what stores hive box representing single conversation
  /// based on Messages subcollection listener
  final conversations = Conversations();

  /// PpNotifications objects - based on NOTIFICATIONS subcollection listener
  final notifications = Notifications();


  static void login({required String nickname}) {
    LoginProcess(nickname: nickname);
  }


  static String? get getUid => FirebaseAuth.instance.currentUser == null
      ? _handleNoCurrentUser()
      : FirebaseAuth.instance.currentUser!.uid;


  static _handleNoCurrentUser() {
    NavigationService.popToBlank();
    ClearState();
  }

}

class ClearState {
  final _states = getIt.get<States>();
  final logService = getIt.get<LogService>();
  ClearState() {
    logService.log('[START] ClearState');
    _states.notifications.clear();
    _states.conversations.clear();
    _states.contacts.clear();
    _states.contactUids.clear();
    _states.me.clear();
    logService.log('[STOP] ClearState');
  }
}