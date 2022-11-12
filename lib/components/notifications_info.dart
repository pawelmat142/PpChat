import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/screens/forms/others/form_styles.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';

class NotificationInfo extends StatefulWidget {
  const NotificationInfo({Key? key}) : super(key: key);

  @override
  State<NotificationInfo> createState() => _NotificationInfoState();
}

class _NotificationInfoState extends State<NotificationInfo> {

  final notificationService = getIt.get<PpNotificationService>();

  String unreadNotifications = "0";
  String totalNotifications = "0";

  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = notificationService.streamCtrl.stream.listen((snapshot) {
      setState(() {
        unreadNotifications = snapshot.where((notification) => !notification.isRead).toList().length.toString();
        totalNotifications = snapshot.length.toString();
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: primaryButtonPadding,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, NotificationsScreen.id),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(width: 2, color: Colors.grey),
            borderRadius: BorderRadius.circular(primaryButtonBorderRadius),
          ),
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text('You have $unreadNotifications unread notifications, $totalNotifications in total.'),
          ),
        ),
      ),
    );

  }
}
