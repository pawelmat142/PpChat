import 'package:another_flushbar/flushbar_route.dart';
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

  static List<String?> get routePath => NavigationHistoryObserver()
      .history.map((route) => route.settings.name).toList();

  static bool get isContactsScreenInStack => routePath.contains(ContactsScreen.id);


  static pop({int? delay}) async {
    if (delay != null) {
      await Future.delayed(Duration(milliseconds: delay));
    }
    Navigator.pop(context);
  }

  static popToHome() {
    Navigator.popUntil(context, ModalRoute.withName(ContactsScreen.id));
  }

  static popToBlank() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static homeAndContacts() {
    popToHome();
    // Navigator.pushNamedAndRemoveUntil(NavigationService.context, ContactsScreen.id, ModalRoute.withName(HomeScreen.id));
  }

  static isConversationOpen({required String uid}) {
    final conversationRouteIndex = NavigationHistoryObserver().history
        .indexWhere((p0) => p0.settings.name == ConversationView.id);
    if (conversationRouteIndex != -1) {
      final conversationRoute = NavigationHistoryObserver().history[conversationRouteIndex];
      final conversationUser = conversationRoute.settings.arguments as PpUser;
      return conversationUser.uid == uid;
    }
    return false;
  }

  static isUserViewOpen({required String uid}) {
    final userRouteIndex = NavigationHistoryObserver().history
        .indexWhere((p0) => p0.settings.name == UserView.id);
    if (userRouteIndex != -1) {
      final userRoute = NavigationHistoryObserver().history[userRouteIndex];
      final user = userRoute.settings.arguments as PpUser;
      return user.uid == uid;
    }
    return false;
  }

  static isFlushbarOpen() {
    return NavigationHistoryObserver().history.indexWhere((p0) => p0 is FlushbarRoute) != -1;
  }

  static popHomeIfAnyUserView({required String uid}) {
    if (isUserViewOpen(uid: uid) || isConversationOpen(uid: uid)) {
      popToHome();
      final popup = getIt.get<Popup>();
      popup.show('Contact deleted!', error: true);
    }
  }

}