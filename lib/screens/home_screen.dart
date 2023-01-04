import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notifications_info.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/process/delete_account_process.dart';
import 'package:flutter_chat_app/process/login_process.dart';
import 'package:flutter_chat_app/models/user/me.dart';
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
        final process = LoginProcess();
        await process.process();
        PpSnackBar.login();
    });
  }

  @override
  void dispose() {
    // final process = LogoutProcess();
    // process.process();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final authService = getIt.get<AuthenticationService>();

    return Scaffold(

      appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [IconButton(onPressed: authService.onLogout , icon: const Icon(Icons.logout))],
          title: Consumer<Me>(builder: (context, me, child) => Text(me.isNotEmpty ? me.nickname : 'xx')),
      ),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Column(
            children: [

              const NotificationInfo(),

              PpButton(text: 'LOGOUT',
                onPressed: authService.onLogout,
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
                    PpSnackBar.show('eeelo!');
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
