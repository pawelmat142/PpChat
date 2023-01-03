import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

abstract class PpSnackBar {

  static BuildContext get context => NavigationService.context;

  static deleted({int delay = 0}) => show('Deleted successfully!', delay: delay);

  static login() => show('Welcome!');
  static logout() => show('You are logged out');

  static invitationSent() => show('Invitation successfully sent!', delay: 100);
  static invitationDeleted() => show('Invitation successfully deleted!');
  static invitationAcceptances() => show('Your invitation has been accepted!');
  static contactNotExists() => show('Contact does not exist!');


  static show(String text, {
    int delay = 0,
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    if (delay > 0) {
      await Future.delayed(Duration(milliseconds: delay));
    }
    final snackBar = SnackBar(
      content: Text(text),
      duration: duration,
    );
    _go(snackBar);
  }

  static _go(SnackBar snackBar) => ScaffoldMessenger.of(context).showSnackBar(snackBar);
}