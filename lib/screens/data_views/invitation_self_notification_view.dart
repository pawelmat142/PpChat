import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/screens/data_views/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class InvitationSelfNotificationView extends NotificationView {
  InvitationSelfNotificationView(super.notification, {super.key});

  final invitationService = getIt.get<InvitationService>();

  @override
  get title => 'YOUR INVITATION';

  @override
  String get nickname => notification.receiver;

  @override
  get content => 'You sent an invitation!';

  @override
  get buttons {
    return [

      PpButton(text: 'cancel invitation', onPressed: () {
        popup.show('Shure?', error: true,
            buttons: [PopupButton('Yes', onPressed: () {
            invitationService.onCancelSentInvitation(super.notification);
            NavigationService.pop(delay: 100);
        })]);
      }),


      PpButton(text: 'remove notification', color: Colors.red, onPressed: () {
        Navigator.pop(NavigationService.context);
        notificationService.onRemoveNotification(notification);
        PpSnackBar.deleted();
      })
    ];
  }

}