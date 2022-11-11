import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';

class PpNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();

  late CollectionReference<Map<String, dynamic>> _myNotifications;

  PpNotificationService() {
    _myNotifications = _firestore.collection(Collections.User)
        .doc(_userService.nickname)
        .collection(Collections.NOTIFICATIONS);
  }

  myNotificationsAsStream() {
    return _myNotifications.snapshots();
  }

}