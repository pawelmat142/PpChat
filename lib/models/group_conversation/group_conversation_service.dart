import 'package:flutter_chat_app/models/group_conversation/group_conversation.dart';

class GroupConversationService {


  startNewConversation() async {
    final conversation = GroupConversation.create(name: 'first');
    await conversation.set(conversation);
  }
}