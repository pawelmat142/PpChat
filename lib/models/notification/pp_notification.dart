import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_fields.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';

class PpNotification {
  final String sender;
  final String receiver;
  final String type;
  bool isRead;
  final String text;

  PpNotification({
    required this.sender,
    required this.receiver,
    required this.type,
    required this.isRead,
    required this.text
  });

  Map<String, dynamic> get asMap => {
    PpNotificationFields.sender: sender,
    PpNotificationFields.receiver: receiver,
    PpNotificationFields.type: type,
    PpNotificationFields.isRead: isRead,
    PpNotificationFields.text: text,
  };

  static PpNotification fromMap(Map<String, dynamic> notificationMap) {
    PpNotificationFields.validate(notificationMap);
    return PpNotification(
      sender: notificationMap[PpNotificationFields.sender],
      receiver: notificationMap[PpNotificationFields.receiver],
      type: notificationMap[PpNotificationFields.type],
      isRead: notificationMap[PpNotificationFields.isRead],
      text: notificationMap[PpNotificationFields.text],
    );
  }

  static PpNotification fromDB(QueryDocumentSnapshot<Object?> doc) {
    try {
      return PpNotification.fromMap(doc.data() as Map<String, dynamic>);
    } catch (error) {
      throw Exception(['FIREBASE OBJECT CAST TO MAP ERROR - NOTIFICATION']);
    }
  }

  static PpNotification createInvitation({required String text, required String sender, required String receiver}) => PpNotification(
      sender: sender,
      receiver: receiver,
      type: PpNotificationTypes.invitation,
      isRead: false,
      text: text
  );

  static PpNotification createInvitationSelfNotification({required String text, required String sender, required String receiver}) => PpNotification(
      sender: sender,
      receiver: receiver,
      type: PpNotificationTypes.invitationSelfNotification,
      isRead: true,
      text: text
  );

  static PpNotification createContactRemove({required String sender, required String receiver}) => PpNotification(
      sender: sender,
      receiver: receiver,
      type: PpNotificationTypes.contactDeletedNotification,
      isRead: true,
      text: PpNotificationTypes.contactDeletedNotification
  );

  static List<PpNotification> filterUnread(List<PpNotification> input) {
    return input.where((notification) => !notification.isRead).toList();
  }

  static List<PpNotification> getUnread(List input) {
    return input.isEmpty ? [] : filterUnread(input as List<PpNotification>);
  }

  static List<PpNotification> filterInvitationAcceptances(List<PpNotification> input) {
    return input.where((notification) => notification.type == PpNotificationTypes.invitationAcceptance && !notification.isRead).toList();
  }

  static List<PpNotification> filterContactDeletedNotifications(List<PpNotification> input) {
    return input.where((notification) => notification.type == PpNotificationTypes.contactDeletedNotification).toList();
  }
}