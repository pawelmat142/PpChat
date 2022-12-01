import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/notifications_info.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/process/delete_account_process.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home_screen';


  @override
  Widget build(BuildContext context) {

    final authService = getIt.get<AuthenticationService>();
    final userService = getIt.get<PpUserService>();

    return Scaffold(

      appBar: AppBar(title: Text('HOME SCREEN - ${userService.nickname}')),

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
