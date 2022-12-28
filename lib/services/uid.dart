import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/process/logout_process.dart';

class Uid {

  static String? get get => FirebaseAuth.instance.currentUser == null
      ? _handleNoCurrentUser()
      : FirebaseAuth.instance.currentUser!.uid;

  static _handleNoCurrentUser() {
    NavigationService.popToBlank();
    final process = LogoutProcess();
    process.process();
  }

}