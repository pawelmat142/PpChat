import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/data_screens/user_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class InvitationView extends NotificationView {
  InvitationView(super.notification, {super.key});

  @override
  get title => 'INVITATION';

  @override
  get content => 'Invites you to contacts!';

  @override
  get buttons {
    return [

      PpButton(
        text: 'ACCEPT',
        onPressed: () async {
          try {
            spinner.start();
            await contactsService.acceptInvitationForReceiver(notification);
            Future.delayed(const Duration(milliseconds: 1000), () {
              final user = contactsService.getUserByNickname(notification.sender);
              NavigationService.popToHome();
              Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
              UserView.navigate(user);
            });
            spinner.stop();
          } catch (error) {
            spinner.stop();
            popup.show('acceptInvitationForReceiver');
          }
        }
      ),

      PpButton(
        text: 'REJECT',
        color: PRIMARY_COLOR_DARKER,
        onPressed: () {
          super.notificationService.deleteInvitation(super.notification);
        }
      ),

    ];
  }

}