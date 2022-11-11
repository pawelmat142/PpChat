import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_tile.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/process/find_contact.dart';

class ContactsScreen extends StatelessWidget {
  ContactsScreen({Key? key}) : super(key: key);
  static const String id = 'contacts_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('CONTACTS')),

      body: ListView(
        padding: const EdgeInsets.only(top: TILE_PADDING_VERTICAL*2),
        children: const [
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
          ContactTile(nickname: 'Nickname', text: 'some more text'),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => FindContact(),
        elevation: 15,
        child: const Icon(Icons.search, size: 40),
      ),

    );
  }
}