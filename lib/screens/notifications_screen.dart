import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notification_tile.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:provider/provider.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  static const String id = 'notifications_screen';

  // Notifications get notifications => notificationService.notifications;

  List<NotificationTile> _notificationTilesMapper(List<PpNotification> notifications) {
    notifications.sort((a, b) => (b.isRead ? 0 : 1));
    return notifications.map((n) => NotificationTile(n)).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('NOTIFICATIONS')),

      body: ListView(
        padding: const EdgeInsets.only(top: BASIC_TOP_PADDING_VALUE),
        children: [
          Consumer<Notifications>(builder: (context, notifications, child) {
            return notifications.isNotEmpty

                ? Column(children: _notificationTilesMapper(notifications.get))

                : nothingHereWidget();


          }),
          // StreamBuilder<List<PpNotification>>(
          //     initialData: notifications.toScreen,
          //     stream: notifications.toScreenStream,
          //     builder: (context, snapshot) {
          //       return snapshot.data != null && snapshot.data!.isNotEmpty
          //
          //           ? Column(children: _notificationTilesMapper(snapshot))
          //
          //           : nothingHereWidget();
          //     }
          // ),
          removeAllButton(),

        ],
      ),
    );
  }

  removeAllButton() => Padding(
    padding: BASIC_HORIZONTAL_PADDING,
    child: PpButton(text: 'remove all', color: Colors.red, onPressed: () {
      final notificationService = getIt.get<PpNotificationService>();
      notificationService.onRemoveAll();
  }));

  nothingHereWidget() {
    return const Center(child: Text('Nothing here'));
  }

}