import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/data_screens/conversation_view.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/data_screens/user_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class InvitationAcceptanceView extends NotificationView {
  InvitationAcceptanceView(super.notification, {super.key});

  @override
  get title => 'INVITATION ACCEPTANCE';

  @override
  get content => 'Accepted your invitation!';

  @override
  get nickname => notification.receiver;

  @override
  get buttons {
    return [

      PpButton(text: 'show user', onPressed: () async {
        try {
          NavigationService.popToHome();
          final user = super.contactsService.getUserByNickname(notification.receiver);
          Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
          UserView.navigate(user);
        } catch (error) {
          popup.sww(text: 'getUserByNickname');
        }
      }),

      PpButton(text: 'Write message', onPressed: () async {
          NavigationService.popToHome();
          Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
          ConversationView.navigate(notification.receiver);
      }),

      PpButton(text: 'remove notification', color: Colors.red, onPressed: () async {
        try {
          await notificationService.deleteSingleNotificationBySenderNickname(notification.sender);
          Navigator.pop(NavigationService.context);
          PpFlushbar.notificationDeleted();
        } catch (error) {
          popup.sww(text: 'deleteSingleNotification');
        }
      }),

    ];
  }
}