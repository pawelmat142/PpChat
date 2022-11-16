import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/screens/forms/others/form_styles.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';

class NotificationInfo extends StatefulWidget {
  NotificationInfo({Key? key}) : super(key: key);

  final notificationService = getIt.get<PpNotificationService>();

  @override
  State<NotificationInfo> createState() => _NotificationInfoState();
}


class _NotificationInfoState extends State<NotificationInfo> {

  String unreadNotifications = "X";
  String totalNotifications = "X";

  StreamSubscription? notificationsListenerOne;

  @override
  void initState() {
    super.initState();
    notificationsListenerOne = widget.notificationService.stream.listen(_setState);
  }

  _setState(event) {
    if (event != null) {
      setState(() {
        unreadNotifications = PpNotification.filterUnread(event as List<PpNotification>).length.toString();
        totalNotifications = event.length.toString();
      });
    }
  }

  @override
  void dispose() {
    notificationsListenerOne!.cancel();
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
