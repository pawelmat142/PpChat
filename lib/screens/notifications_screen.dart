import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notification_tile.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';

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
    notificationsListenerTwo = widget.notificationService.stream.map(_notificationTilesMapper).listen(_setState);
  //TODO: sort notifications - unread first
  }

  List<NotificationTile> _notificationTilesMapper(event) {
    return event != null ? (event as List<PpNotification>).map((n) => NotificationTile(n)).toList() : [];
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
          children: tiles,
        ),
    );
  }
}