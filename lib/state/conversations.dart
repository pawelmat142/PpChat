import 'package:flutter_chat_app/state/conversation.dart';
import 'package:flutter_chat_app/state/interfaces/data_state_object.dart';

class Conversations extends DataStateObject<Conversation> {
  Conversations() {
    reactiveModeOn = false;
  }

  @override
  int getItemIndex(Conversation item) => state.indexWhere((conversation) =>
    conversation.contactNickname == item.contactNickname);

  int indexByNickname(String contactNickname) => state.indexWhere((conversation) =>
    conversation.contactNickname == contactNickname);

  Conversation? getByNickname(String contactNickname) {
    final index = indexByNickname(contactNickname);
    return index != -1 ? state[index] : null;
  }

  bool exists({required String contactNickname}) {
    return indexByNickname(contactNickname) != -1;
  }


  openOrCreate({required contactNickname}) async {
    final conversation = getByNickname(contactNickname);
    if (conversation == null) {
      addEvent(await Conversation.create(contactNickname: contactNickname));
    }
    else if (!conversation.isOpen) {
      await conversation.open();
    }
  }

  @override
  deleteOneEvent(Conversation item) => throw Exception('killBoxAndDelete should be used instead!');

  killBoxAndDelete(Conversation item) async {
    await item.killBox();
    super.deleteOneEvent(item);
  }


  @override
  clear() async {
    for (var conversation in state) {
      await conversation.box.compact();
      await conversation.box.clear();
    }
    super.clear();
  }

}