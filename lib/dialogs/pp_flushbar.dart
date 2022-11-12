import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';

class PpFlushbar {

  static void invitationNotification() {
    Flushbar? bb;
    bb = basic(
      title: 'New contacts invitation',
      message: 'Tap to checkout',
      icon: const Icon(Icons.person_add, size: 30, color: Colors.white),
      duration: const Duration(seconds: 10),
      onTap: () {
        // TODO: navigate to invitation view and mark it as read
        Navigator.pushNamed(NavigationService.context, NotificationsScreen.id);
      },
    );
    bb.show(NavigationService.context);
  }

  static showBasic(){
    final basicFlushbar = basic();
    basicFlushbar.show(NavigationService.context);
  }

  static Flushbar basic({
    String title = 'Title',
    String message = 'Message',
    Duration duration = const Duration(seconds: 5),
    Icon? icon,
    Function? onTap,
    bool hideButtonEnable = true,
    TextButton? mainButton
  }) {
    Flushbar? bar;
    TextButton? mainButton;

    if (hideButtonEnable) {
      mainButton = TextButton(
        onPressed: () => bar!.dismiss(),
        child: const Text('HIDE')
      );
    }

    bar = Flushbar(
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
    return bar;
  }
}