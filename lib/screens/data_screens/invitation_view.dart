import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';

class InvitationView extends NotificationView {
  InvitationView(super.notification, {super.key});

  final contactsService = getIt.get<ContactsService>();
  final spinner = getIt.get<PpSpinner>();

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
          await contactsService.acceptInvitationForReceiver(super.notification);
          Navigator.pop(NavigationService.context);
          await Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
          //  TODO: add push navigate to direct contact view
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