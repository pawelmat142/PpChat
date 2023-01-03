import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:provider/provider.dart';

class Conversations with ChangeNotifier {

  static Conversations get reference => Provider.of<Conversations>(NavigationService.context, listen: false);

  List<Conversation> _state = [];
  List<Conversation> get get => _state;

  Future<Conversation> openOrCreate({required String contactUid}) async {
    final conversation = getByUid(contactUid);
    if (conversation == null) {
      _addOne(await Conversation.create(contactUid: contactUid));
    }
    else if (!conversation.isOpen) {
      await conversation.open();
    }
    return getByUid(contactUid)!;
  }

  Conversation? getByUid(String contactUid) {
    final index = indexByUid(contactUid);
    return index != -1 ? _state[index] : null;
  }

  int indexByUid(String uid) => _state.indexWhere((conversation) =>
    conversation.contactUid == uid);

  clear() async {
    for (var conversation in _state) {
      await conversation.box.compact();
    }
    _state = [];
    notifyListeners();
  }

  clearBoxes() async {
    for (var conversation in _state) {
      await conversation.box.compact();
      await conversation.box.clear();
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