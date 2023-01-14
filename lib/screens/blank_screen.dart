import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/forms/register_form_screen.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/screens/forms/login_form_screen.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/received_notification.dart';
import 'package:flutter_chat_app/services/second_page.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


//start local_notifications purposes
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();

final selectNotificationStream = StreamController<String?>.broadcast();

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

int id = 0;
//stop local_notifications purposes


class BlankScreen extends StatefulWidget {
  static const String id = 'blank_screen';

  const BlankScreen({
    this.notificationAppLaunchDetails,
    Key? key}) : super(key: key);


  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;


  @override
  State<BlankScreen> createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {


  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();

    print('init');

    //local_notifications purposes
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    print('init222');
  }


  @override
  Widget build(BuildContext context) {

    if (Uid.get != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, ContactsScreen.id);
      });
    }

    return Scaffold(

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Center(
          child:
              !_notificationsEnabled
              ? const CircularProgressIndicator()

              : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    _InfoValueString(
                      title: 'Did notification launch app?',
                      value: widget.didNotificationLaunchApp,
                    ),

                    PpButton(
                        text: 'LOGIN',
                        onPressed: () => Navigator.pushNamed(context, LoginFormScreen.id),
                    ),

                    PpButton(
                        text: 'REGISTER',
                        onPressed: () => Navigator.pushNamed(context, RegisterFormScreen.id),
                        color: PRIMARY_COLOR_DARKER,
                    ),

                    PpButton(
                        text: 'Show plain notification with payload?',
                        onPressed: () async {
                          await _showNotification();
                        },
                    ),

                    PpButton(text: 'log aaaaaa',
                      onPressed: () {
                        final authService = getIt.get<AuthenticationService>();
                        authService.onLogin(nickname: 'aaaaaa', password: 'aaaaaa');
                        },
                      ),

                      PpButton(
                      text: 'log bbbbbb',
                      onPressed: () {
                        final authService = getIt.get<AuthenticationService>();
                        authService.onLogin(nickname: 'bbbbbb', password: 'bbbbbb');
                      },
                      ),

                      PpButton(
                      text: 'log cccccc',
                      onPressed: () {
                        final authService = getIt.get<AuthenticationService>();
                        authService.onLogin(nickname: 'cccccc', password: 'cccccc');
                        },
                      ),

                  ]
                ),
          ),
        ),
      ),
    );
  }

  //local_notifications purposes - everything under
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  //not used yet
  Future<String> getInitialRoute() async {
    String initialRoute = BlankScreen.id;

    final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
        Platform.isLinux
        ? null
        : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse?.payload;

      //route by notification
      initialRoute = BlankScreen.id;
    }

    return initialRoute;
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      setState(() {
        _notificationsEnabled = granted ?? false;
      });
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondPage(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => SecondPage(payload),
      ));
    });
  }
}



class _InfoValueString extends StatelessWidget {
  const _InfoValueString({
    required this.title,
    required this.value,
    Key? key,
  }) : super(key: key);

  final String title;
  final Object? value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
    child: Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: '$title ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: '$value',
          )
        ],
      ),
    ),
  );

}