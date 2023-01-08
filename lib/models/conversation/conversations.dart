import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:provider/provider.dart';

class Conversations with ChangeNotifier {

  static Conversations get reference => Provider.of<Conversations>(NavigationService.context, listen: false);

  List<Conversation> _state = [];
  List<Conversation> get get => _state;

  bool pending = false;

  Future<Conversation> openOrCreate({required String contactUid}) async {
    final conversation = getByUid(contactUid);
    if (conversation == null) {
      final newConversation = Conversation.create(contactUid: contactUid);
      _addOne(newConversation);
      await newConversation.open();
      return newConversation;
    }
    else if (!conversation.isOpen) {
      await conversation.open();
    }
    final result = getByUid(contactUid)!;
    return result;
  }

  Conversation? getByUid(String contactUid) {
    final index = indexByUid(contactUid);
    return index != -1 ? _state[index] : null;
  }

  int indexByUid(String uid) => _state.indexWhere((conversation) =>
    conversation.contactUid == uid);

  clear() async {
    for (var conversation in _state) {
      await conversation.box!.compact();
      conversation.messageCleaner.dispose();
    }
    _state = [];
    notifyListeners();
  }

  clearBoxes() async {
    for (var conversation in _state) {
      await conversation.box!.compact();
      await conversation.box!.clear();
    }
    _state = [];
    notifyListeners();
  }



  _addOne(Conversation item) {
    _state.add(item);
    notifyListeners();
  }

  deleteByUid(String uid) {
    final index = indexByUid(uid);
    if (index != -1) {
      _state.removeAt(index);
      notifyListeners();
    }
  }


}