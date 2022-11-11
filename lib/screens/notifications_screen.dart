import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notification_tile.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});
  static const String id = 'notifications_screen';

  final _notificationsService = getIt.get<PpNotificationService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('NOTIFICATIONS')),

      body: StreamBuilder<QuerySnapshot>(
          stream: _notificationsService.myNotificationsAsStream(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

            if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
              return ListView(
                  padding: const EdgeInsets.only(top: TILE_PADDING_VERTICAL*2),
                  children: snapshot.data!.docs.map((doc) {
                    return NotificationTile(PpNotification.fromDB(doc));
                  }).toList()
              );

            } else {
              return const Center(child: Text('nothing here'));
            }
          }
      ),
    );
  }

}
