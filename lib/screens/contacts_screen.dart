import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_tile.dart';
import 'package:flutter_chat_app/components/notifications_info.dart';
import 'package:flutter_chat_app/components/tile_divider.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/process/find_contact.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);
  static const String id = 'contacts_screen';

  PpUser get me => Me.reference.get;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () => UserView.navigate(user: me),
                icon: AvatarWidget(
                  uid: me.uid,
                  model: Me.reference.get.avatar,
                  size: 50,
                ),
            )
          ],
          title: const Text('CONTACTS')
      ),

      body: ListView(
        children: [

          const Padding(
            padding: BASIC_HORIZONTAL_PADDING,
            child: NotificationInfo()
          ),
          const TileDivider(),

          Consumer<Contacts>(builder: (context, contacts, child) {
            return contacts.isNotEmpty

                ? Column(children: contacts.get.map((u) => ContactTile(u)).toList())

                : nothingHereWidget();
          })
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