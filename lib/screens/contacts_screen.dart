import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_tile.dart';
import 'package:flutter_chat_app/components/notifications_info.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/process/find_contact.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/process/login_process.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);
  static const String id = 'contacts_screen';

  static navigate(BuildContext context) {
    if (Uid.get != null && !NavigationService.isContactsScreenInStack) {
      Future.delayed(Duration.zero, () => Navigator.pushNamed(context, ContactsScreen.id));
    }
  }

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  PpUser get me => Me.reference.get;

  final spinner = getIt.get<PpSpinner>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      spinner.start(context: context);
      final process = LoginProcess();
      await process.process();
      spinner.stop(context: context);
      Future.delayed(Duration.zero, ()  {
        PpSnackBar.login();
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

          leading: IconButton(icon: const Icon(Icons.logout),
            onPressed: () {
              final authService = getIt.get<AuthenticationService>();
              authService.onLogout();
            },
          ),
          title: const Text('CONTACTS'),
          actions: [
            IconButton(
                onPressed: () => UserView.navigate(user: me),
                icon: Consumer<Me>(
                builder: (context, me, child) => me.isNotEmpty ?
                  AvatarWidget(
                    uid: me.uid,
                    model: me.get.avatar,
                    size: 50)
                  : const SizedBox(height: 0)
                ),
            ),
          ],

          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(36),
            child: NotificationInfo()
          ),
      ),

      body: ListView(
        children: [

          Padding(
            padding: const EdgeInsets.only(top: BASIC_TOP_PADDING_VALUE),
            child: Consumer<Contacts>(builder: (context, contacts, child) {
              return contacts.isNotEmpty

                  ? Column(children: contacts.get.map((u) => ContactTile(u)).toList())

                  : nothingHereWidget();
            }),
          ),
          
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => FindContact(),
        elevation: 15,
        child: const Icon(Icons.search, size: 40),
      ),

    );
  }

  nothingHereWidget() {
    return const Center(child: Text('Nothing here'));
  }
}