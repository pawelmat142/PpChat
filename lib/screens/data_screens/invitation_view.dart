import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';

class InvitationView extends NotificationView {
  InvitationView(super.notification, {super.key});

  final contactsService = getIt.get<ContactsService>();

  @override
  get title => 'INVITATION';

  @override
  get content => 'Invites you to contacts!';

  @override
  get buttons {
    return [

      PpButton(
        text: 'ACCEPT',
        onPressed: () {
          contactsService.acceptInvitation(super.notification);
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