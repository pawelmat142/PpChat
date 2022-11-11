import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_avatar.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';

class NotificationTile extends StatelessWidget {
  final PpNotification notification;
  const NotificationTile(this.notification, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    Content(title: notification.type, text: notification.from),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(right: TILE_PADDING_VERTICAL),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.message, size: 35, color: PRIMARY_COLOR_LIGHTER),
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

    );
  }
}

class Content extends StatelessWidget {
  final String title;
  final String text;
  const Content({Key? key, required this.title, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

          Text(text, style: const TextStyle(
            fontSize: 15,
            color: PRIMARY_COLOR_LIGHTER,
          )),

        ],
      ),
    );
  }

  getTitle() {
    switch(title) {
      case PpNotificationTypes.invitation: return 'Invitation';
      case PpNotificationTypes.message: return 'New message';
      default: return 'Unknown';
    }
  }
}