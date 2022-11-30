import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class InvitationSelfNotificationView extends NotificationView {
  InvitationSelfNotificationView(super.notification, {super.key});

  //TODO: something is wrong here - lets have a look
  @override
  get title => 'YOUR INVITATION';

  @override
  String get nickname => notification.receiver;

  @override
  get content => 'You sent an invitation!';

  @override
  get buttons {
    return [
      PpButton(text: 'cancel invitation', onPressed: () async {
        await super.notificationService.deleteInvitation(super.notification);
      }),

      PpButton(text: 'remove notification', color: Colors.red, onPressed: () async {
        Navigator.pop(NavigationService.context);
        await super.notificationService.deleteSingleNotificationBySenderNickname(super.notification.sender);
      })
    ];
  }

}