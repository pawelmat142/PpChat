import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_settings_view.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/hive_service.dart';
import 'package:flutter_chat_app/services/local_notifications/local_notifications_service.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_view.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/forms/register_form_screen.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await LocalNotificationsService.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //TODO: Notification navigate to conversation/notification

  //TODO: BUG - after create account and invitation/accept invitation - contact doesn't show in contact screen

  //TODO: pass avatar object in notification if is needed (invitation)

  //TODO: icon and splash screens

  //TODO: value of unread messages on icon

  // TODO: add notifications enabled in converssation settings

  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => Me()),
        ChangeNotifierProvider(create: (_) => ContactUids()),
        ChangeNotifierProvider(create: (_) => Contacts()),
        ChangeNotifierProvider(create: (_) => Notifications()),
        ChangeNotifierProvider(create: (_) => Conversations()),
      ],

      child: const MyApp(),
    )
  );

  await initGetIt();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter chat app',
      theme: ThemeData.light(),
      navigatorKey: NavigationService.navigatorKey,
      navigatorObservers: [NavigationHistoryObserver()],
      initialRoute: BlankScreen.id,

      routes: {
        BlankScreen.id: (context) => const BlankScreen(),

        LoginFormScreen.id: (context) => LoginFormScreen(),
        RegisterFormScreen.id: (context) => RegisterFormScreen(),

        ContactsScreen.id: (context) => const ContactsScreen(),

        UserView.id: (context) => const UserView(),

        ConversationView.id: (context) => const ConversationView(),

        ConversationSettingsView.id: (context) => const ConversationSettingsView(),

        NotificationsScreen.id: (context) => const NotificationsScreen(),
      },
    );
  }
}