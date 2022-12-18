import 'package:flutter_chat_app/state/conversation.dart';
import 'package:flutter_chat_app/state/interfaces/data_state_object.dart';

class Conversations extends DataStateObject<Conversation> {
  Conversations() {
    reactiveModeOn = false;
  }

  @override
  int getItemIndex(Conversation item) => state.indexWhere((conversation) =>
    conversation.contactUid == item.contactUid);

  int indexByUid(String uid) => state.indexWhere((conversation) =>
    conversation.contactUid == uid);

  Conversation? getByUid(String contactUid) {
    final index = indexByUid(contactUid);
    return index != -1 ? state[index] : null;
  }

  bool exists({required String contactUid}) {
    return indexByUid(contactUid) != -1;
  }


  openOrCreate({required String contactUid}) async {
    final conversation = getByUid(contactUid);
    if (conversation == null) {
      addEvent(await Conversation.create(contactUid: contactUid));
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
    }
    super.clear();
  }

  clearBoxes() async {
    for (var conversation in state) {
      await conversation.box.compact();
      await conversation.box.clear();
    }
    super.clear();
  }

}