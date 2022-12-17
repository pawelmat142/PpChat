import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class InvitationView extends NotificationView {
  InvitationView(super.notification, {super.key});

  final invitationService = getIt.get<InvitationService>();

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
            await invitationService.onAcceptInvitation(notification);
            Future.delayed(const Duration(milliseconds: 100), () {
              NavigationService.popToHome();
              Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
              // UserView.navigate(contactsService.getUserByNickname(notification.sender));
            });
            spinner.stop();
          } catch (error) {
            spinner.stop();
            popup.sww(text: 'acceptInvitationForReceiver');
          }
        }
      ),

      PpButton(
        text: 'REJECT',
        color: PRIMARY_COLOR_DARKER,
        onPressed: () {
          popup.show('Shure?', error: true, buttons: [
            PopupButton('Yes', color: Colors.deepOrange, onPressed: () {
              invitationService.onRejectReceivedInvitation(notification);
              NavigationService.pop();
          })]);
        }
      ),

    ];
  }

}