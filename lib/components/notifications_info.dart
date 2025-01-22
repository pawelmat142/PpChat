import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/screens/forms/others/form_styles.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';
import 'package:provider/provider.dart';

class NotificationInfo extends StatelessWidget {
  const NotificationInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, left: 5, right: 5),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, NotificationsScreen.id),
        child: Container(
          decoration: BoxDecoration(
            color: PRIMARY_COLOR_LIGHTER,
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(primaryButtonBorderRadius))
          ),
          padding: const EdgeInsets.all(10),
          child: Center(child: Consumer<Notifications>(
            builder: (context, notifications, child) {
              final unreadNotifications =
                  PpNotification.getUnread(notifications.get).length.toString();
              final totalNotifications = notifications.get.length.toString();
              return Text(
                  'Notifications: $totalNotifications      Unread: $unreadNotifications',
                style: const TextStyle(
                    color: WHITE_COLOR,
                    letterSpacing: 1,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
