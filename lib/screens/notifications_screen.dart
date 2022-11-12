import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notification_tile.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  static const String id = 'notifications_screen';

  @override
  Widget build(BuildContext context) {

    final notificationsService = getIt.get<PpNotificationService>();
    final list = notificationsService.currentNotifications;

    return Scaffold(

      appBar: AppBar(title: const Text('NOTIFICATIONS')),

      body: list.isEmpty
        ? const Center(child: Text('Nothing here'))

        : ListView(
          padding: const EdgeInsets.only(top: TILE_PADDING_VERTICAL*2),
          children: list.map((notification) => NotificationTile(notification)).toList(),
        ),
    );
  }

}