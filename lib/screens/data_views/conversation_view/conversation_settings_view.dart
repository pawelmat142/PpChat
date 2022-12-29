import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

class ConversationSettingsView extends StatelessWidget {
  const ConversationSettingsView({Key? key}) : super(key: key);

  static const String id = 'conversation_settings_view';

  static navigate(String contactUid) {
    Navigator.pushNamed(
        NavigationService.context,
        ConversationSettingsView.id,
        arguments: contactUid
    );
  }

  @override
  Widget build(BuildContext context) {

    final contactUid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(

      appBar: AppBar(title: const Text('Conversation settings')),

      body: Center(child: Text(contactUid)),
    );
  }
}
