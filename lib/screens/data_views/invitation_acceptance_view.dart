import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/screens/data_views/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';

class InvitationAcceptanceView extends NotificationView {
  InvitationAcceptanceView(super.notification, {super.key});

  final conversationService = getIt.get<ConversationService>();

  @override
  get title => 'Invitation accepted';

  @override
  get content => 'Accepted your invitation!';

  @override
  get nickname => notification.sender;

  @override
  get buttons {
    return [

      PpButton(text: 'show user', onPressed: () async {
        NavigationService.homeAndContacts();
        final user = super.contactsService.getByNickname(nickname: notification.sender);
        if (user != null) UserView.navigate(user: user);
      }),

      PpButton(text: 'Write message', onPressed: () async {
        NavigationService.homeAndContacts();
        final user = contactsService.getByUid(uid: notification.documentId);
        if (user != null) conversationService.navigateToConversationView(user);
      }),

      PpButton(text: 'remove notification', color: Colors.red, onPressed: () async {
          await notificationService.onRemoveNotification(notification);
          Navigator.pop(NavigationService.context);
          PpSnackBar.deleted();
      }),

    ];
  }
}