import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/local_notifications_service.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/screens/data_views/notification_view.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';

class PpFlushbar {

  static String get route => NavigationService.route;

  static void invitationNotification(PpNotification notification) {
    if (NavigationService.isFlushbarOpen()) return;
    Flushbar? flushbar;
    flushbar = basic(
      title: 'New contacts invitation',
      message: 'Tap to checkout',
      icon: const Icon(Icons.person_add, size: 30, color: Colors.white),
      duration: const Duration(seconds: 10),
      onTap: () {
        flushbar!.dismiss();
        NotificationView.navigate(notification);
      },
    );
    flushbar.show(NavigationService.context);
  }


  static void multipleNotifications({required int value, int? delay}) async {
    if (NavigationService.isFlushbarOpen()) return;
    Flushbar? flushbar;
    flushbar = basic(
      title: 'You have $value notifications!',
      message: 'Tap to checkout',
      icon: const Icon(Icons.comments_disabled, size: 30, color: Colors.white),
      duration: const Duration(seconds: 10),
      onTap: () {
        flushbar!.dismiss();
        Navigator.pushNamed(NavigationService.context, NotificationsScreen.id);
      },
    );
    flushbar.show(NavigationService.context);
  }


  static void comingMessages({required List<PpMessage> messages, int? delay}) async {
    final localNotificationsService = getIt.get<LocalNotificationsService>();
    localNotificationsService.messageNotification(messages: messages);

    // final title = messages.length == 1
    //   ? 'You have new message'
    //   : 'You have ${messages.length} new messages';
    // final contactsLength = messages.map((m) => m.sender).toSet().length;
    // Flushbar? flushbar;
    // flushbar = basic(
    //   title: title,
    //   message: 'Tap to checkout',
    //   icon: const Icon(Icons.comments_disabled, size: 30, color: Colors.white),
    //   duration: const Duration(seconds: 10),
    //   onTap: () {
    //     flushbar!.dismiss();
    //     if (contactsLength == 1) {
    //       final conversationService = getIt.get<ConversationService>();
    //       final contactUser = conversationService.getContactUserByUid(messages.first.sender);
    //       if (contactUser != null) {
    //         conversationService.navigateToConversationView(contactUser);
    //       }
    //     } else {
    //       NavigationService.popToHome();
    //       Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
    //     }
    //   },
    // );
    // flushbar.show(NavigationService.context);
  }

  static showBasic(){
    final basicFlushbar = basic();
    basicFlushbar.show(NavigationService.context);
  }

  static Flushbar basic({
    String title = 'Title',
    String? message,
    Duration duration = const Duration(seconds: 5),
    Icon? icon,
    Function? onTap,
    bool hideButtonEnable = true,
    TextButton? mainButton
  }) {
    Flushbar? flushbar;
    TextButton? mainButton;

    if (hideButtonEnable) {
      mainButton = TextButton(
        onPressed: () => flushbar!.dismiss(),
        child: const Text('HIDE')
      );
    }

    flushbar = Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.only(top: 10, left: 6, right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      borderRadius: BorderRadius.circular(15),
      title: title,
      message: message,
      duration: duration,
      icon: icon,
      mainButton: mainButton,
      onTap: onTap != null ? (x) => onTap() : (x){},
    );
    return flushbar;
  }
}