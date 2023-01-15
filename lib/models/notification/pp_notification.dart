import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_fields.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_model.dart';
import 'package:flutter_chat_app/services/uid.dart';

class PpNotification {
  final String documentId;
  final String sender;
  final String receiver;
  final String type;
  bool isRead;
  bool isFlushed;
  bool isResolved;
  final String text;
  final AvatarModel avatar;

  PpNotification({
    required this.documentId,
    required this.sender,
    required this.receiver,
    required this.type,
    required this.isRead,
    required this.isFlushed,
    required this.isResolved,
    required this.text,
    required this.avatar,
  });

  Map<String, dynamic> get asMap => {
    PpNotificationFields.documentId: documentId,
    PpNotificationFields.sender: sender,
    PpNotificationFields.receiver: receiver,
    PpNotificationFields.type: type,
    PpNotificationFields.isRead: isRead,
    PpNotificationFields.isFlushed: isFlushed,
    PpNotificationFields.isResolved: isResolved,
    PpNotificationFields.text: text,
    PpNotificationFields.avatar: avatar.asMap,
  };

  static PpNotification fromMap(Map<String, dynamic> notificationMap) {
    PpNotificationFields.validate(notificationMap);
    return PpNotification(
      documentId: notificationMap[PpNotificationFields.documentId],
      sender: notificationMap[PpNotificationFields.sender],
      receiver: notificationMap[PpNotificationFields.receiver],
      type: notificationMap[PpNotificationFields.type],
      isRead: notificationMap[PpNotificationFields.isRead],
      isFlushed: notificationMap[PpNotificationFields.isFlushed],
      isResolved: notificationMap[PpNotificationFields.isResolved],
      text: notificationMap[PpNotificationFields.text],
      avatar: AvatarModel.fromMap(notificationMap[PpNotificationFields.avatar]),
    );
  }

  static PpNotification fromDB(DocumentSnapshot<Object?> doc) {
    return PpNotification.fromMap(doc.data() as Map<String, dynamic>);
  }

  static PpNotification createInvitation({
    required String text,
    required String sender,
    required String receiver,
    required AvatarModel avatar
  }) => PpNotification(
      documentId: Uid.get!,
      sender: sender,
      receiver: receiver,
      type: PpNotificationTypes.invitation,
      isRead: false,
      isFlushed: false,
      isResolved: true,
      text: text,
      avatar: avatar
  );

  static PpNotification createInvitationAcceptance({
    required String text,
    required String sender,
    required String receiver,
    required String documentId,
    required AvatarModel avatar
  }) => PpNotification(
      documentId: documentId,
      sender: sender,
      receiver: receiver,
      type: PpNotificationTypes.invitationAcceptance,
      isRead: false,
      isFlushed: false,
      isResolved: false,
      text: text,
      avatar: avatar
  );

  static PpNotification createInvitationSelfNotification({
    required String text,
    required String sender,
    required String receiver,
    required String documentId,
    required AvatarModel avatar
  }) => PpNotification(
      documentId: documentId,
      sender: sender,
      receiver: receiver,
      type: PpNotificationTypes.invitationSelfNotification,
      isRead: true,
      isFlushed: true,
      isResolved: true,
      text: text,
      avatar: avatar
  );

  static PpNotification createContactDeleted({
    required String sender,
    required String receiver,
    required AvatarModel avatar
  }) => PpNotification(
      documentId: Uid.get!,
      sender: sender,
      receiver: receiver,
      type: PpNotificationTypes.contactDeletedNotification,
      isRead: true,
      isFlushed: true,
      isResolved: false,
      text: PpNotificationTypes.contactDeletedNotification,
      avatar: avatar
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