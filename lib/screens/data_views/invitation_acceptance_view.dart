import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/data_views/notification_view.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';

class InvitationAcceptanceView extends NotificationView {
  InvitationAcceptanceView(super.notification, {super.key});

  final conversationService = getIt.get<ConversationService>();

  @override
  get title => 'INVITATION ACCEPTANCE';

  @override
  get content => 'Accepted your invitation!';

  @override
  get nickname => notification.sender;

  @override
  get buttons {
    return [

      PpButton(text: 'show user', onPressed: () async {
        NavigationService.popToHome();
        final user = super.contactsService.getByNickname(nickname: notification.sender);
        Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
        if (user != null) UserView.navigate(user);
      }),

      PpButton(text: 'Write message', onPressed: () async {
          NavigationService.popToHome();
          Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
          final contactUser = conversationService.getContactUserByNickname(notification.receiver);
          if (contactUser != null) conversationService.navigateToConversationView(contactUser);
      }),

      PpButton(text: 'remove notification', color: Colors.red, onPressed: () async {
          await notificationService.onRemoveNotification(notification);
          Navigator.pop(NavigationService.context);
          PpFlushbar.notificationDeleted();
      }),

    ];
  }
}