import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/process/accept_invitation_process.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/screens/data_views/notification_view.dart';
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
        onPressed: () => _onAcceptInvitation(),
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

  _onAcceptInvitation() async {
    try {
      NavigationService.homeAndContacts();
      spinner.start();
      final process = AcceptInvitationProcess(invitation: notification);
      await process.process();
      spinner.stop();
      final user = contactsService.getByUid(uid: notification.documentId);
      if (user != null) UserView.navigate(user: user);
    } catch (error) {
      spinner.stop();
      popup.sww(text: 'acceptInvitationForReceiver');
    }
  }

}