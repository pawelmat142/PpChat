import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
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
    bool first = true;
    _listener = _myNotificationsCollectionRef.snapshots().listen((querySnapshot) {
      final notifications = querySnapshot.docs.map((doc) => PpNotification.fromMap(doc.data())).toList();
      if (!first) _notificationFlush(notifications);
      _current = notifications;
      streamCtrl.sink.add(notifications);
      first = false;
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

  _notificationFlush(List<PpNotification> newList) async {
    final newNotification = _getNewOneFromList(newList);
    if (newNotification != null) {
      if (newNotification.type == PpNotificationTypes.invitation) {
        PpFlushbar.invitationNotification();
      } else {
        PpFlushbar.showBasic();
      }
    }
  }

  PpNotification? _getNewOneFromList(List<PpNotification> newList) {
    if (listEquals(newList, _current)) return null;
    final currentNotificationsFroms = _current.map((n) => n.from).toList();
    List<PpNotification> result = newList.where((n) => !currentNotificationsFroms.contains(n.from)).toList();
    return result.isNotEmpty ? result.first : null;
  }
}