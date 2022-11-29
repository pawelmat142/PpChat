import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class ConversationService {

  final _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();
  final _contactsService = getIt.get<ContactsService>();
  final _popup = getIt.get<Popup>();


  CollectionReference get messagesCollectionRef => _firestore
      .collection(Collections.User).doc(_userService.nickname)
      .collection(Collections.Messages);

  CollectionReference getReceiverCollectionRef(String receiver) => _firestore
      .collection(Collections.User).doc(receiver)
      .collection(Collections.Messages);


  // < nickname, hiveBox>
  Map<String, Box<PpMessage>> _conversationsBoxes = {};

  //TODO add contact = add conversation box

  login() async {
    for (var receiverNickname in _contactsService.currentContactNicknames) {
      final box = await Hive.openBox<PpMessage>(_getHiveConversationKey(receiverNickname));
      _conversationsBoxes[receiverNickname] = box;
    }
  }

  logout() async {
    await Hive.close();
    for (var key in _conversationsBoxes.keys) {
      _conversationsBoxes.remove(key);
    }
    print('logged out');
  }

  Box<PpMessage> getConversationBox(String receiverNickname) {
    if (_conversationsBoxes[receiverNickname] == null) _noBoxException();
    return _conversationsBoxes[receiverNickname]!;
  }

  onSendMessage(PpMessage message) async {
    try {
      await _addMessageToHive(message);
      await _sendMessageToReceiver(message);
    } catch (error) {
      _popup.sww();
    }
  }

  _addMessageToHive(PpMessage message) async {
    final box = _conversationsBoxes[message.receiver];
    box != null ? await box.add(message) : _noBoxException();
  }

  _sendMessageToReceiver(PpMessage message) async {
    await getReceiverCollectionRef(message.receiver).add(message.asMap);
  }


  _getHiveConversationKey(String receiverNickname) {
    return 'conversation_${_userService.nickname}_$receiverNickname}';
  }

  _noBoxException() {
    throw Exception(['no such conversation box']);
  }

  deleteBox(String receiverNickname) async {
    //TODO: delete when delete account
    _conversationsBoxes.remove(receiverNickname);
    await Hive.box(_getHiveConversationKey(receiverNickname)).deleteFromDisk();
    print('deleted');
  }

  deleting() async {
    Hive.deleteFromDisk();
  }


}