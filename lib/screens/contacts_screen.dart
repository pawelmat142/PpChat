import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_tile.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/process/find_contact.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);
  static const String id = 'contacts_screen';

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('CONTACTS')),

      body: ListView(
        padding: const EdgeInsets.only(top: TILE_PADDING_VERTICAL*2),
        children: [

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