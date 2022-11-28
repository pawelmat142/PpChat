import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_avatar.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';

class NotificationTile extends StatelessWidget {
  final PpNotification notification;
  const NotificationTile(this.notification, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => NotificationView.navigate(notification),
      child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TILE_PADDING_HORIZONTAL, vertical: TILE_PADDING_VERTICAL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Row(
                    children: [
                      const ContactAvatar(),
                      getContent(),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: TILE_PADDING_VERTICAL),
                    child: Icon(Icons.message,
                      color: notification.isRead ? Colors.green : Colors.red,
                      size: 35,
                    ),
                  ),

                ],
              ),
            ),

            const Divider(
              thickness: 1,
              color: Colors.grey,
              endIndent: TILE_PADDING_HORIZONTAL,
              indent: TILE_PADDING_HORIZONTAL * 3 + CONTACTS_AVATAR_SIZE,
            ),
          ]

      ),
    );
  }

  getContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TILE_PADDING_HORIZONTAL*2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(getTitle(), style: const TextStyle(
              fontSize: 18,
              color: PRIMARY_COLOR_DARKER,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5
          )),

          const SizedBox(height: 4),

          Text(getNickname(), style: const TextStyle(
            fontSize: 15,
            color: PRIMARY_COLOR_LIGHTER,
          )),

        ],
      ),
    );
  }

  getNickname() {
    return notification.type == PpNotificationTypes.invitationAcceptance
        ? notification.receiver
        : notification.sender;
  }

  getTitle() {
    switch(notification.type) {
      case PpNotificationTypes.invitation: return 'Invitation';
      case PpNotificationTypes.invitationSelfNotification: return 'Your invitation';
      case PpNotificationTypes.invitationAcceptance: return 'Invitation accepted';
      case PpNotificationTypes.message: return 'New message';
      default: return 'Unknown';
    }
  }
}