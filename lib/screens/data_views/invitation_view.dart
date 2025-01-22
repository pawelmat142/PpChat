import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
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
  InvitationView(super.notification, {PpUser? contactUser, super.key});

  final invitationService = getIt.get<InvitationService>();

  @override
  get title => 'Invitation';

  @override
  get content => 'Invites you to contacts!';

  @override
  get buttons {
    return [

      PpButton(
        text: 'Accept',
        onPressed: () => _acceptInvitation(),
      ),

      PpButton(
        text: 'Reject',
        color: PRIMARY_COLOR_DARKER,
        onPressed: () {
          popup.show('Sure?', error: true, buttons: [
            PopupButton('Yes', color: Colors.deepOrange, onPressed: () {
              invitationService.rejectReceivedInvitation(notification);
              NavigationService.pop();
          })]);
        }
      ),

    ];
  }

  _acceptInvitation() async {
    try {
      NavigationService.homeAndContacts();
      spinner.start();
      await AcceptInvitationProcess(invitation: notification).process();
      spinner.stop();
      final PpUser? user = contactsService.getByUid(uid: notification.documentId);
      if (user != null) {
        UserView.navigate(user: user);
      }
    } catch (error) {
      spinner.stop();
      popup.sww(text: 'acceptInvitationForReceiver');
    }
  }

}