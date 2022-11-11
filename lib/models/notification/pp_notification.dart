import 'package:flutter_chat_app/models/notification/pp_notification_fields.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';

class PpNotification {
  final String from;
  final String type;
  bool isRead;
  final String text;

  PpNotification({
    required this.from,
    required this.type,
    required this.isRead,
    required this.text
  });

  Map<String, dynamic> get asMap => {
    PpNotificationFields.from: from,
    PpNotificationFields.type: type,
    PpNotificationFields.isRead: isRead,
    PpNotificationFields.text: text,
  };

  static PpNotification fromMap(Map<String, dynamic> notificationMap) {
    PpNotificationFields.validate(notificationMap);
    return PpNotification(
      from: notificationMap[PpNotificationFields.from],
      type: notificationMap[PpNotificationFields.type],
      isRead: notificationMap[PpNotificationFields.isRead],
      text: notificationMap[PpNotificationFields.text],
    );
  }

  static PpNotification createInvitation({required String text, required String fromNickname}) => PpNotification(
      from: fromNickname,
      type: PpNotificationTypes.invitation,
      isRead: false,
      text: text
  );
}