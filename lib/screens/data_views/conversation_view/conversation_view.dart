import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/message_bubble.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_mock.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_popup_menu.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/message_input.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:hive_flutter/adapters.dart';

class ConversationView extends StatelessWidget {
  const ConversationView({super.key});
  static const id = 'conversation_view';


  static navigate(PpUser contact) {
    Navigator.pushNamed(
      NavigationService.context,
      ConversationView.id,
      arguments: contact
    );
  }


  @override
  Widget build(BuildContext context) {

    final contactUser = ModalRoute.of(context)!.settings.arguments as PpUser;
    final conversationService = getIt.get<ConversationService>();
    final conversation = conversationService.conversations.getByUid(contactUser.uid)!;

    bool isMock(Box<PpMessage> box) => box.values.length == 1 && box.values.first.isMock;

    conversationService.resolveUnresolvedMessages();

    return Scaffold(

      appBar: AppBar(
          title: Text(contactUser.nickname),
          actions: [
            ConversationPopupMenu(conversation: conversation),
          ]
      ),

      body: SafeArea(
        child: Column(children: [

          //MESSAGES AREA
          Expanded(child: ValueListenableBuilder<Box<PpMessage>>(
              valueListenable: conversation.box.listenable(),
              builder: (context, box, _) {

                if (box.values.isEmpty) return const Center(child: Text('empty!'));

                if (isMock(box)) return MessageMock(box.values.first, contactUser);

                conversationService.markAsRead(box);

                final interfaces = box.values.map((m) => MessageBubbleInterface(
                    message: m.message,
                    my: m.sender == Uid.get,
                    timestamp: m.timestamp)
                ).toList();

                interfaces.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                int dayBefore = 0;
                for (var i in interfaces.reversed) {
                  if (i.timestamp.day != dayBefore) {
                    i.divider = true;
                    dayBefore = i.timestamp.day;
                  }
                }

                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  children: interfaces.map((i) => MessageBubble(interface: i)).toList(),
                );
              })
          ),

          MessageInput(contactUser: contactUser),

        ]),
      ),
    );
  }

}