import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_fields.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';

class PpNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();
  final _contactsService = getIt.get<ContactsService>();
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();

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
  //add to sink = refresh notifications screen view
  final _controller = StreamController.broadcast();
  get stream => _controller.stream;

  Future<void> login() {
    var completer = Completer();
    bool first = true;
    _userService.authValidate(where: 'notification service');
    _firestoreListener = _myNotificationsCollectionRef.snapshots().listen((querySnapshot) async {
      final notifications = querySnapshot.docs.map((doc) => PpNotification.fromMap(doc.data())).toList();
      if (notifications.isEmpty) {
        if (!completer.isCompleted) completer.complete();
      } else {
        if (!first) _notificationFlush(notifications);
        _current = notifications;
        _controller.sink.add(notifications);
        await _contactsService.resolveInvitationAcceptancesForSender(_current);
        await _contactsService.resolveContactDeletedNotificationsForReceiver(_current);
        first = false;
        if (!completer.isCompleted) completer.complete();
      }
    }, onError:(error) {
      print(error);
      _current = [];
      _controller.sink.add([]);
      if (!completer.isCompleted) completer.complete();
    });
    print('notifications service initialized');
    return completer.future;
  }

  logout() {
    _firestoreListener!.cancel();
    _current = [];
    _controller.sink.add([]);
    print('notification service logged out');
  }

  //TODO: send invitation navigate to notifications

  isInvitationReceived(String nickname) {
    for (var notification in _current) {
      if (notification.sender == nickname && notification.type == PpNotificationTypes.invitation) {
        return true;
      }
    }
    return false;
  }

  isInvitationSent(String nickname) {
    for (var notification in _current) {
      if (notification.receiver == nickname && notification.type == PpNotificationTypes.invitationSelfNotification) {
        return true;
      }
    }
    return false;
  }

  _notificationFlush(List<PpNotification> newList) async {
    final newNotification = _getNewOneFromList(newList);
    if (newNotification != null) {
      if (newNotification.type == PpNotificationTypes.invitation) {
        PpFlushbar.invitationNotification(newNotification);
      } else {
        PpFlushbar.showBasic();
      }
    }
  }

  PpNotification? _getNewOneFromList(List<PpNotification> newList) {
    if (listEquals(newList, _current)) return null;
    final currentNotificationsFroms = _current.map((n) => n.sender).toList();
    List<PpNotification> result = newList.where((n) => !currentNotificationsFroms.contains(n.sender)).toList();
    return result.isNotEmpty ? result.first.isRead ? null : result.first : null;
  }

  _imSender(PpNotification notification) {
    return _userService.nickname == notification.sender;
  }

  markNotificationAsRead(PpNotification notification) {
    _myNotificationsCollectionRef
        .doc(_imSender(notification) ? notification.receiver : notification.sender)
        .update({PpNotificationFields.isRead: true});
  }

  deleteSingleNotificationBySenderNickname(String senderNickname) async {
    final index = _current.indexWhere((n) => n.sender == senderNickname);
    if (index != -1) {
      final notification = _current[index];
      await _deleteSingleNotification(notification);
      _removeFromCurrentByIndex(index);
    } else {
      throw Exception('no such notification!');
    }
  }

  _deleteSingleNotification(PpNotification notification) async {
    await _myNotificationsCollectionRef.doc(notification.sender).delete();
  }

  _removeFromCurrentByIndex(int index) {
    _current.removeAt(index);
    _controller.sink.add(_current);
  }

  deleteInvitation(PpNotification notification) async {
    final index = _current.indexWhere((n) => n.sender == notification.sender);
    if (index == -1) return;
    await _popup.show('Are you sure?', buttons: [
      PopupButton('Yes', onPressed: () async {
          Navigator.pop(NavigationService.context);
          _spinner.start();
          final batch = _firestore.batch();
          batch.delete(_myNotificationsCollectionRef.doc(_imSender(notification) ? notification.receiver : notification.sender));
          batch.delete(_getAnotherUserNotificationDocumentRef(notification, isSender: _imSender(notification)));
          await batch.commit();
          _removeFromCurrentByIndex(index);
          _spinner.stop();
          PpFlushbar.invitationDeleted(delay: 100);
        })
    ]);
  }

  DocumentReference _getAnotherUserNotificationDocumentRef(PpNotification notification, {bool isSender = false})  {
    return _firestore.collection(Collections.User)
        .doc(isSender ? notification.receiver : notification.sender)
        .collection(Collections.NOTIFICATIONS)
        .doc(isSender ? notification.sender : notification.receiver);
  }

  deleteAllNotifications() async {
    try {
      final batch = _firestore.batch();
      for (var notification in _current) {
        batch.delete(_myNotificationsCollectionRef.doc(_imSender(notification) ? notification.receiver : notification.sender));
        if (notification.type != PpNotificationTypes.contactDeletedNotification) {
          batch.delete(_getAnotherUserNotificationDocumentRef(notification, isSender: _imSender(notification)));
        }
      }
      await batch.commit();
    } catch (error) {
      _spinner.stop();
      _popup.sww(text: 'delete all notifications error');
    }
  }

  deleteAllNotificationsPopup() {
    _popup.show('Are you shure?',
        text: 'All notification will be deleted also for senders',
        error: true,
        buttons: [PopupButton('Delete', onPressed: () async {
          _spinner.start();
          await deleteAllNotifications();
          _spinner.stop();
          PpFlushbar.notificationsDeleted();
        })]);
  }

}