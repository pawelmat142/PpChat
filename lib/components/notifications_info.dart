import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/screens/forms/others/form_styles.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';
import 'package:provider/provider.dart';

class NotificationInfo extends StatelessWidget {
  const NotificationInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: primaryButtonPadding,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, NotificationsScreen.id),
        child: Container(
          decoration: BoxDecoration(
            color: PRIMARY_COLOR_LIGHTER.withOpacity(0.2),
            shape: BoxShape.rectangle,
            border: Border.all(width: 1, color: PRIMARY_COLOR_LIGHTER),
            borderRadius: BorderRadius.circular(primaryButtonBorderRadius),
          ),
          padding: const EdgeInsets.all(10),
          child: Center(child: Consumer<Notifications>(
            builder: (context, notifications, child) {
              final unreadNotifications =
                  PpNotification.getUnread(notifications.get).length.toString();
              final totalNotifications = notifications.get.length.toString();
              return Text(
                  'You have $unreadNotifications unread notifications, $totalNotifications in total.');
            }),
          ),
        ),
      ),
    );
  }
}
