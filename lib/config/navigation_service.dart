import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static get context {
    return navigatorKey.currentContext;
  }

  static String get route {
    if (NavigationHistoryObserver().top != null) {
      if (NavigationHistoryObserver().top!.settings.name != null) {
        return NavigationHistoryObserver().top!.settings.name!;
      }
    }
    return '';
  }

  static pop({int? delay}) async {
    if (delay != null) {
      await Future.delayed(Duration(milliseconds: delay));
    }
    Navigator.pop(context);
  }

  static popToHome() {
    Navigator.popUntil(context, ModalRoute.withName(HomeScreen.id));
  }

  static popToBlank() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}