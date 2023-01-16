import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

class NotificationController {

  static initAwesomeNotifications() {
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: const Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        debug: true
    );
  }

  static init() {
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
    print('NOTIFICATION CONTROLLER');
    print('onNotificationCreatedMethod');
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    print('NOTIFICATION CONTROLLER');
    print('onNotificationDisplayedMethod');
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    print('NOTIFICATION CONTROLLER');
    print('onDismissActionReceivedMethod');
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    print('NOTIFICATION CONTROLLER');
    print('onActionReceivedMethod');
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    NavigationService.context.currentState?.pushNamedAndRemoveUntil('/notification-page',
            (route) => (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
  //   if (!isAllowed) {
  //   // This is just a basic example. For real apps, you must show some
  //   // friendly dialog box before call the request method.
  //   // This is very important to not harm the user experience
  //   AwesomeNotifications().requestPermissionToSendNotifications();
  //   }
  //   });
}