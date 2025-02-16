import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
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
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

import '../../../models/crypto/hive_rsa_pair.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});
  static const id = 'conversation_view';

  static navigate(PpUser contact) {
    Navigator.pushNamed(
      NavigationService.context,
      ConversationView.id,
      arguments: contact
    );
  }

  static popAndNavigate(PpUser contact) {
    Navigator.popAndPushNamed(
        NavigationService.context,
        ConversationView.id,
        arguments: contact
    );
  }

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {

  final conversationService = getIt.get<ConversationService>();
  final notificationService = getIt.get<PpNotificationService>();

  bool isMock(Box<PpMessage> box) => box.values.length == 1 && box.values.first.isMock;

  PpUser? _contactUser;
  PpUser get contactUser => _contactUser!;

  late RSAPrivateKey _myPrivateKey;
  late Conversation conversation;

  bool initialized = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _myPrivateKey = (await HiveRsaPair.getMyPrivateKey())!;
      conversation = await Conversations.reference.openOrCreate(contactUid: contactUser.uid);
      await conversation.refreshPublicKey();
      conversationService.resolveUnresolvedMessages();
      notificationService.dismiss(contactUid: contactUser.uid);
      setState(() => initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {

    _contactUser ??= ModalRoute.of(context)!.settings.arguments as PpUser;

    return Scaffold(

      appBar: AppBar(
          title: Text(contactUser.nickname),
          actions: !initialized ? [] : [
            ConversationPopupMenu(conversation: conversation),
          ]
      ),

      body: SafeArea(
        child: !initialized
        ? const Center(child: CircularProgressIndicator()) :

        Column(children: [

          //MESSAGES AREA
          Expanded(child: ValueListenableBuilder<Box<PpMessage>>(
              valueListenable: conversation.box!.listenable(),
              builder: (context, box, _) {

                if (!box.isOpen || box.values.isEmpty) {
                  return const Center(child: Text('empty!'));
                }

                ///MOCK MESSAGES
                ///are not encrypted!
                if (isMock(box)) {
                  return MessageMock(box.values.first, contactUser);
                }

                conversationService.markAsRead(box);

                final interfaces = box.values
                    .where((m) => m.message != '' && !m.isMock)
                    .map((m) => MessageBubbleInterface(
                      message: m.receiver == Uid.get
                          ? decrypt(m.message, _myPrivateKey)
                          : m.message,
                      my: m.sender == Uid.get,
                      timestamp: m.timestamp,
                      readTimestamp: m.readTimestamp,
                      timeToLive: m.timeToLive,
                      timeToLiveAfterRead: m.timeToLiveAfterRead)
                  ).toList();

                interfaces.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                int dayBefore = 0;
                for (var message in interfaces.reversed) {
                  if (message.timestamp.day != dayBefore) {
                    message.divider = true;
                    dayBefore = message.timestamp.day;
                  }
                }

                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  children: interfaces.map((i) => MessageBubble(interface: i)).toList(),
                );
              })
          ),

          MessageInput(conversation: conversation),

        ]),
      ),
    );
  }
}