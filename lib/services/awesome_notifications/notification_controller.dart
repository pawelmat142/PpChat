import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_view.dart';
import 'package:flutter_chat_app/screens/data_views/notification_view.dart';
import 'package:flutter_chat_app/services/app_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
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

  static const String notificationsChannelKey = 'pp_chat';

  static void notifyMessage({required String contactUid}) {
    if (!getIt.get<AppService>().isAppInBackground) {
      if (NavigationService.isUserConversationOpen(contactUid)) return;
      // if (NavigationService.isContactsOpen) return;
    }
    AwesomeNotifications().createNotification(content: NotificationContent(
        id: getIdByUid(contactUid), //unique id for each contact
        channelKey: notificationsChannelKey,
        title: 'You have new message...',
        actionType: ActionType.Default,
        payload: {
          PayloadFields.uid: contactUid,
          PayloadFields.type: PayloadTypes.message
        }
      ));
  }

  static void notifyInvitation({required String contactUid}) {
    AwesomeNotifications().createNotification(content: NotificationContent(
        id: getIdByUid(contactUid), //unique id for each contact
        channelKey: notificationsChannelKey,
        title: 'You have new invitation...',
        actionType: ActionType.Default,
        payload: {
          PayloadFields.uid: contactUid,
          PayloadFields.type: PayloadTypes.invitation
        }
    ));
  }

  static void dismiss({required String contactUid}) {
    AwesomeNotifications().dismiss(getIdByUid(contactUid));
  }

  static int getIdByUid(String uid) {
    return int.parse(uid.substring(0, 6), radix: 36);
  }


  static initAwesomeNotifications() {
    AwesomeNotifications().initialize(
        null, //default icon
        [
          NotificationChannel(
              channelKey: notificationsChannelKey,
              channelName: 'PpChat notifications',
              channelDescription: 'PpChat notifications',
              channelShowBadge: true,
              // defaultColor: PRIMARY_COLOR,
              ledColor: Colors.white
          )
        ],
        debug: true
    );
  }

  static initListeners() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // print('NOTIFICATION CONTROLLER');
    // print('onNotificationCreatedMethod');
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // print('NOTIFICATION CONTROLLER');
    // print('onNotificationDisplayedMethod');
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // print('NOTIFICATION CONTROLLER');
    // print('onDismissActionReceivedMethod');
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