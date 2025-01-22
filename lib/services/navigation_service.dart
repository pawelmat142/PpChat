import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_view.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static get context => navigatorKey.currentContext;

  static get routes => NavigationHistoryObserver().history;

  static bool get isContactsScreenInStack => routes
      .map((route) => route.settings.name)
      .contains(ContactsScreen.id);

  static bool get isContactsOpen {
    final lastRoute = routes.last;
    if (lastRoute.settings.name == ContactsScreen.id) {
      return true;
    }
    return false;
  }


  static bool isUserConversationOpen(String contactUid) {
    final lastRoute = routes.last;
    if (lastRoute.settings.name == ConversationView.id) {
      final user = lastRoute.settings.arguments;
      if (lastRoute.settings.arguments is PpUser) {
        if ((user as PpUser).uid == contactUid) {
          return true;
        }
      }
    }
    return false;
  }

  static bool isUserViewOpen(String contactUid) {
    final lastRoute = routes.last;
    if (lastRoute.settings.name == UserView.id) {
      final user = lastRoute.settings.arguments;
      if (lastRoute.settings.arguments is PpUser) {
        if ((user as PpUser).uid == contactUid) {
          return true;
        }
      }
    }
    return false;
  }

  static pop({int? delay}) async {
    if (delay != null) {
      await Future.delayed(Duration(milliseconds: delay));
    }
    Navigator.pop(context);
  }

  static popToHome({BuildContext? ctx}) {
    Navigator.popUntil(ctx ?? context, ModalRoute.withName(ContactsScreen.id));
  }

  static popToBlank() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static homeAndContacts() {
    popToHome();
    // Navigator.pushNamedAndRemoveUntil(NavigationService.context, ContactsScreen.id, ModalRoute.withName(HomeScreen.id));
  }

  static popHomeIfAnyUserView({required String uid}) {
    if (isUserViewOpen(uid) || isUserConversationOpen(uid)) {
      popToHome();
      final popup = getIt.get<Popup>();
      popup.show('Contact deleted!', error: true);
    }
  }

}