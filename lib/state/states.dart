import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/models/provider/clear_data.dart';
import 'package:flutter_chat_app/state/conversations.dart';

class States {

  /// Conversations object stores Conversation objects what stores hive box representing single conversation
  /// based on Messages subcollection listener
  final conversations = Conversations();

  /// PpNotifications objects - based on NOTIFICATIONS subcollection listener
  // final notifications = Notifications();


  static String? get getUid => FirebaseAuth.instance.currentUser == null
      ? _handleNoCurrentUser()
      : FirebaseAuth.instance.currentUser!.uid;


  static _handleNoCurrentUser() {
    NavigationService.popToBlank();
    final process = ClearData(NavigationService.context);
    process.process();
    // ClearState();
  }

}