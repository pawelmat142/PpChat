import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class NotificationView extends StatelessWidget {
  final PpNotification notification;
  NotificationView(this.notification, {Key? key}) : super(key: key);

  final _notificationService = getIt.get<PpNotificationService>();

  @override
  Widget build(BuildContext context) {

    if (!notification.isRead) {
      _notificationService.markNotificationAsRead(docId: notification.from);
    }

    return Scaffold(

      appBar: AppBar(title: Text(getTitle())),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: getView(),
      ),
    );
  }

  getTitle() {
    switch(notification.type) {
      case PpNotificationTypes.invitation: return 'INVITATION';
      default: return 'UNKNOWN';
    }
  }

  getView() {
    switch(notification.type) {
      case PpNotificationTypes.invitation: return _invitationView();
      default: return const Center(child: Text('UNKNOWN'));
    }
  }

  /// INVITATION VIEW
  _invitationView() {
    return Column(
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

      const Text(' Invites you to contacts',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          letterSpacing: 0.8,
        ),
      ),

      //MESSAGE
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: RichText(text: TextSpan(children: [
          const TextSpan(text: 'Message: ', style: TextStyle(fontSize: 16, color: PRIMARY_COLOR_LIGHTER)),
          TextSpan(text: notification.text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ])),
      ),

      PpButton(
        text: 'ACCEPT',
        onPressed: (){
        //  TODO: accept invitation, add to contacts, delete notification
        }
      ),

      PpButton(
        text: 'REJECT',
        color: PRIMARY_COLOR_DARKER,
        onPressed: (){
        //    TODO: reject invitation, delete notification
        }
      ),
    ]);
  }
}
