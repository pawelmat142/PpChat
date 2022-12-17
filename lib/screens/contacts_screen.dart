import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_tile.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/process/find_contact.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/state/contacts.dart';

class ContactsScreen extends StatelessWidget {
  ContactsScreen({Key? key}) : super(key: key);
  static const String id = 'contacts_screen';

  final contactsService = getIt.get<ContactsService>();
  Contacts get contacts => contactsService.contacts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('CONTACTS')),

      body: ListView(
        padding: const EdgeInsets.only(top: TILE_PADDING_VERTICAL*2),
        children: [
          StreamBuilder<List<PpUser>>(
              initialData: contacts.get,
              stream: contacts.stream,
              builder: (context, snapshot) {
                return snapshot.data != null && snapshot.data!.isNotEmpty

                    ? Column(children: snapshot.data!.map((u) => ContactTile(u)).toList())

                    : nothingHereWidget();
              }
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