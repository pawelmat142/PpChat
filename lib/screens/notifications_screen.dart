import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notification_tile.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});
  static const String id = 'notifications_screen';

  final notificationService = getIt.get<PpNotificationService>();

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}


class _NotificationsScreenState extends State<NotificationsScreen> {

  StreamSubscription? notificationsListenerTwo;
  List<Widget> tiles = [];

  @override
  void initState() {
    super.initState();
    tiles = _notificationTilesMapper(widget.notificationService.currentNotifications);
    notificationsListenerTwo = widget.notificationService.stream
        .map(_notificationTilesMapper)
        .listen(_setState);
  }

  List<NotificationTile> _notificationTilesMapper(event) {
    List<PpNotification> list = event == null ? [] : event as List<PpNotification>;
    list.sort((a, b) => (b.isRead ? 0 : 1));
    return list.map((n) => NotificationTile(n)).toList();
  }

  _setState(event) {
    if (event != null) {
      setState(() => tiles = event as List<NotificationTile>);
    }
  }


  @override
  void dispose() {
    notificationsListenerTwo!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('NOTIFICATIONS')),

      body: tiles.isEmpty
        ? const Center(child: Text('nothing here'))

        : ListView(
          padding: const EdgeInsets.only(top: TILE_PADDING_VERTICAL*2),
          children: [

            Column(children: tiles),

            Padding(
              padding: BASIC_HORIZONTAL_PADDING,
              child: PpButton(text: 'DELETE ALL', color: Colors.red, onPressed: () {
                widget.notificationService.deleteAllNotificationsPopup();
              }),
            )

          ],
        ),
    );
  }
}