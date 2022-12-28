import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/screens/blank_screen.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_view.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/screens/forms/register_form_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PpMessageAdapter());

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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        HomeScreen.id: (context) => const HomeScreen(),
        ContactsScreen.id: (context) => const ContactsScreen(),
        NotificationsScreen.id: (context) => const NotificationsScreen(),
        LoginFormScreen.id: (context) => LoginFormScreen(),
        RegisterFormScreen.id: (context) => RegisterFormScreen(),
        ConversationView.id: (context) => const ConversationView(),
      },
    );
  }
}