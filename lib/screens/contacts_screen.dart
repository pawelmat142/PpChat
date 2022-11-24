import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_tile.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/process/find_contact.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';

class ContactsScreen extends StatefulWidget {
  ContactsScreen({Key? key}) : super(key: key);
  static const String id = 'contacts_screen';

  final contactsService = getIt.get<ContactsService>();

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}


class _ContactsScreenState extends State<ContactsScreen> {

  List<Widget> tiles = [];

  buildState() {
    setState(() {
      buildTiles();
    });
  }

  buildTiles() {
    tiles = widget.contactsService.currentContactUsers.map((user) => ContactTile(nickname: user.nickname, text: user.role)).toList();
  }

  @override
  void initState() {
    buildTiles();
    super.initState();
    widget.contactsService.setStateToContactsScreen = buildState;
  }

  @override
  void dispose() {
    widget.contactsService.setStateToContactsScreen = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('CONTACTS')),

      body: ListView(
        children: [

          Column(children: tiles),

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