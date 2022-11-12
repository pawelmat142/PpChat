import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';

class PpNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();

  CollectionReference<Map<String, dynamic>> get _myNotificationsCollectionRef {
    return _firestore.collection(Collections.User)
        .doc(_userService.nickname)
        .collection(Collections.NOTIFICATIONS);
  }

  final StreamController<List<PpNotification>> streamCtrl = StreamController.broadcast();
  Stream<List<PpNotification>> get stream => streamCtrl.stream;
  late StreamSubscription _listener;

  List<PpNotification> _current = [];
  List<PpNotification> get currentNotifications => _current;

  login() {
    _listener = _myNotificationsCollectionRef.snapshots().listen((querySnapshot) {
      final notifications = querySnapshot.docs.map((doc) => PpNotification.fromMap(doc.data())).toList();
      _current = notifications;
      streamCtrl.sink.add(notifications);
    }, onError:(error) {
      _current = [];
      streamCtrl.sink.add([]);
    });
  }

  logout() {
    _listener.cancel();
    _current = [];
    streamCtrl.sink.add([]);
  }
}