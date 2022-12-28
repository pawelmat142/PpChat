import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notifications_info.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/process/delete_account_process.dart';
import 'package:flutter_chat_app/models/provider/init_data.dart';
import 'package:flutter_chat_app/models/provider/me.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
        final process = InitData(context);
        await process.process();
    });
  }

  @override
  Widget build(BuildContext context) {

    final authService = getIt.get<AuthenticationService>();

    return Scaffold(

      appBar: AppBar(title: Consumer<Me>(
        builder: (context, me, child) => Text(me.isNotEmpty ? me.nickname : 'xx')
      )),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Column(
            children: [

              NotificationInfo(),

              PpButton(text: 'LOGOUT',
                onPressed: authService.logout,
              ),

              PpButton(text: 'DELETE ACCOUNT',
                onPressed: onDeleteAccount,
              ),

              PpButton(text: 'CONTACTS',
                onPressed: () => Navigator.pushNamed(context, ContactsScreen.id),
              ),

              PpButton(text: 'test',
                onPressed: () {
                  if (kDebugMode) {
                    print('test');
                  }
                },
              ),

          ]
        ),
      ),
    );
  }

  onDeleteAccount() async {
    final popup = getIt.get<Popup>();

    popup.show('Are you sure?',
        text: 'All your data will be lost!',
        error: true,
        buttons: [PopupButton('Delete', error: true, onPressed: () {
          NavigationService.popToBlank();
          DeleteAccountProcess();
        })]
    );
  }
}
