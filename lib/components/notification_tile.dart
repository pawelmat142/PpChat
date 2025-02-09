import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/tile_divider.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/screens/data_views/notification_view.dart';

class NotificationTile extends StatelessWidget {
  final PpNotification notification;
  NotificationTile(this.notification, {super.key});

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
                      AvatarWidget(
                        uid: notification.documentId,
                        model: notification.avatar,
                      ),
                      getContent(),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: TILE_PADDING_VERTICAL),
                    child: Icon(Icons.note,
                      color: notification.isRead ? Colors.green : Colors.red,
                      size: 35,
                    ),
                  ),

                ],
              ),
            ),

            const TileDivider(),
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

  final reverse = [
    PpNotificationTypes.invitationAcceptance,
    PpNotificationTypes.invitationSelfNotification
  ];

  getNickname() {
    return reverse.contains(notification.type)
        ? notification.receiver
        : notification.sender;
  }

  getTitle() {
    switch(notification.type) {
      case PpNotificationTypes.invitation: return 'Invitation';
      case PpNotificationTypes.invitationSelfNotification: return 'Invitation sent';
      case PpNotificationTypes.invitationAcceptance: return 'Invitation accepted';
      default: return 'Unknown';
    }
  }
}