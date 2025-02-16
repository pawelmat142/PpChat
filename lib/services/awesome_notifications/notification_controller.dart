import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_view.dart';
import 'package:flutter_chat_app/screens/data_views/notification_view.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

abstract class PayloadFields {
  static const String uid = 'uid';
  static const String type = 'type';
}

abstract class PayloadTypes {
  static const String invitation = 'invitation';
  static const String message = 'message';
}

class NotificationController {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    print('NOTIFICATION CONTROLLER onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    print('NOTIFICATION CONTROLLER onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    print('NOTIFICATION CONTROLLER onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.payload != null && receivedAction.payload!.containsKey(PayloadFields.type)) {

      final type = receivedAction.payload![PayloadFields.type];
      final uid = receivedAction.payload![PayloadFields.uid];

      if (type == PayloadTypes.message) {
        final contactUser = Contacts.reference.getByUid(uid!);
        if (contactUser != null) {
          ConversationView.navigate(contactUser);
        }
      }

      if (type == PayloadTypes.invitation) {
        final invitation = Notifications.reference.findBySenderUid(uid!);
        if (invitation != null) {
          NotificationView.navigate(invitation);
        }
      }

    }
    LogService.addLog('navigate by payload - path: ${NavigationService.routes.map((r) => r.settings.name).toList()}');

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // NavigationService.context.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }

}