import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';

abstract class PpNotificationFields {
  static const sender = 'sender';
  static const receiver = 'receiver';
  static const type = 'type';
  static const isRead = 'isRead';
  static const isFlushed = 'isFlushed';
  static const isResolved = 'isResolved';
  static const text = 'text';

  static validate(Map<String, dynamic>? notificationMap) {
    if (notificationMap!.keys.contains(PpNotificationFields.sender)
        && notificationMap[PpNotificationFields.sender] is String
        && notificationMap.keys.contains(PpNotificationFields.receiver)
        && notificationMap[PpNotificationFields.receiver] is String
        && notificationMap.keys.contains(PpNotificationFields.type)
        && PpNotificationTypes.list.contains(notificationMap[PpNotificationFields.type])
        && notificationMap.keys.contains(PpNotificationFields.isRead)
        && notificationMap[PpNotificationFields.isRead] is bool
        && notificationMap.keys.contains(PpNotificationFields.isFlushed)
        && notificationMap[PpNotificationFields.isFlushed] is bool
        && notificationMap.keys.contains(PpNotificationFields.isResolved)
        && notificationMap[PpNotificationFields.isResolved] is bool
        && notificationMap.keys.contains(PpNotificationFields.text)
        && notificationMap[PpNotificationFields.text] is String
    ) {return;} else {
      // throw Exception(["Notification MAP ERROR"]);
    }
  }
}