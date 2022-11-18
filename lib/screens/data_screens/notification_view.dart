import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';

class NotificationView extends StatelessWidget {
  final PpNotification notification;
  final notificationService = getIt.get<PpNotificationService>();

  NotificationView(this.notification, {super.key});

  String get title => 'Notification';
  String get content => 'You have new notification!';
  List<Widget> get buttons => [];

  @override
  Widget build(BuildContext context) {

    if (!notification.isRead) {
      notificationService.markNotificationAsRead(docId: notification.from);
    }

    return Scaffold(

      appBar: AppBar(title: Text(title)),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              //AVATAR
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle
                  ),
                ),
              ),

              //NICKNAME
              Text(notification.from,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  color: PRIMARY_COLOR_DARKER,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 0.8,
                ),
              ),

              //MESSAGE
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: RichText(text: TextSpan(children: [
                  const TextSpan(text: 'Message: ', style: TextStyle(fontSize: 16, color: PRIMARY_COLOR_LIGHTER)),
                  TextSpan(text: notification.text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                ])),
              ),

              //BUTTONS
              Column(children: buttons)

        ]),
      ),
    );
  }
}
