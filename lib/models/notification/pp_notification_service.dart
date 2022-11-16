import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_fields.dart';
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

  //CURRENT VALUE
  List<PpNotification> _current = [];
  List<PpNotification> get currentNotifications => _current;

  //STREAM
  StreamSubscription? _firestoreListener;
  final _controller = StreamController.broadcast();
  get stream => _controller.stream;

  login() {
    bool first = true;
    _firestoreListener = _myNotificationsCollectionRef.snapshots().listen((querySnapshot) {
      final notifications = querySnapshot.docs.map((doc) => PpNotification.fromMap(doc.data())).toList();
      if (!first) _notificationFlush(notifications);
      _current = notifications;
      _controller.sink.add(notifications);
      first = false;
    }, onError:(error) {
      _current = [];
      _controller.sink.add([]);
    });
  }

  logout() {
    _firestoreListener!.cancel();
    _current = [];
    _controller.sink.add([]);
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

  markNotificationAsRead({required String docId}) {
    _myNotificationsCollectionRef.doc(docId).update({PpNotificationFields.isRead: true});
  }
}