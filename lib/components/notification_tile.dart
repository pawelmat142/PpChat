import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_avatar.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';

class NotificationTile extends StatelessWidget {
  final PpNotification notification;
  const NotificationTile(this.notification, {super.key});

  _navigateToNotificationView() {
    Navigator.push(
        NavigationService.context,
        MaterialPageRoute(builder: (context) => NotificationView.factory(notification)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _navigateToNotificationView,
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
                    child: IconButton(
                      onPressed: () {
                      //  TODO: implement swap little bit left and delete icon shows
                      },
                      icon: Icon(Icons.message,
                          color: notification.isRead ? Colors.green : Colors.red,
                          size: 35,
                      ),
                      color: PRIMARY_COLOR,
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

          Text(notification.from, style: const TextStyle(
            fontSize: 15,
            color: PRIMARY_COLOR_LIGHTER,
          )),

        ],
      ),
    );
  }

  getTitle() {
    switch(notification.type) {
      case PpNotificationTypes.invitation: return 'Invitation';
      case PpNotificationTypes.invitationSelfNotification: return 'Your invitation';
      case PpNotificationTypes.message: return 'New message';
      default: return 'Unknown';
    }
  }
}