import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/screens/data_views/invitation_acceptance_view.dart';
import 'package:flutter_chat_app/screens/data_views/invitation_self_notification_view.dart';
import 'package:flutter_chat_app/screens/data_views/invitation_view.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';

class NotificationView extends StatelessWidget {

  //FACTORY PATTERN
  static NotificationView factory(PpNotification notification) {
    switch (notification.type) {
      case PpNotificationTypes.invitation: return InvitationView(notification);
      case PpNotificationTypes.invitationSelfNotification: return InvitationSelfNotificationView(notification);
      case PpNotificationTypes.invitationAcceptance: return InvitationAcceptanceView(notification);
      default: return NotificationView(notification);
    }
  }

  static navigate(PpNotification notification) {
      Navigator.push(
        NavigationService.context,
        MaterialPageRoute(builder: (context) => NotificationView.factory(notification)),
      );
  }

  static popAndNavigate(PpNotification notification, {required BuildContext context}) {
      // Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationView.factory(notification)),
      );
  }

  final PpNotification notification;
  final notificationService = getIt.get<PpNotificationService>();
  final contactsService = getIt.get<ContactsService>();
  final spinner = getIt.get<PpSpinner>();
  final popup = getIt.get<Popup>();

  NotificationView(this.notification, {super.key}) {
    if (!notification.isRead) {
      markAsRead();
    }
  }

  String get title => 'Notification';
  String get content => 'You have new notification!';
  String get nickname => notification.sender;
  List<Widget> get buttons => [];

  markAsRead() {
    notificationService.markNotificationAsRead(notification);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text(title)),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// AVATAR
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: AvatarWidget(
                  uid: notification.documentId,
                  model: notification.avatar,
                  size: AVATAR_SIZE_BIG,
                ),
              ),

              /// NICKNAME
              Text(nickname,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  color: PRIMARY_COLOR_DARKER,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 0.8,
                ),
              ),

              //MESSAGE
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: RichText(text: TextSpan(children: [
                  const TextSpan(text: 'Message: ', style: TextStyle(fontSize: 16, color: PRIMARY_COLOR_LIGHTER)),
                  TextSpan(text: notification.text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                ])),
              ),

              //BUTTONS
              Column(children: buttons)

        ]),
      ),
    );
  }
}
