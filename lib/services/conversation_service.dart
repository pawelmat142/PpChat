import 'dart:async';
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

  CollectionReference getContactMessagesRef(String receiver) => _firestore
      .collection(Collections.User).doc(receiver)
      .collection(Collections.Messages);

  StreamSubscription? listener;
  // < nickname, hiveBox>
  Map<String, Box<PpMessage>> _conversationsBoxes = {};

  login() async {
    //open hive conversation boxes
    for (var contactNickname in _contactsService.currentContactNicknames) {
      final box = await Hive.openBox<PpMessage>(_getHiveConversationKey(contactNickname));
      _conversationsBoxes[contactNickname] = box;
    }

    // listen for coming messages - add to hive and delete from firestore
    listener = messagesCollectionRef.snapshots().listen((event) async {
      for (var change in event.docChanges) {
        try {
          await _addMessageToHive(PpMessage.fromDB(change.doc));
          await change.doc.reference.delete();
        } catch (error) {
          _popup.sww(text: 'receiving message error');
        }
      }
    });
  }

  logout() async {
    for (var key in _conversationsBoxes.keys) {
      _conversationsBoxes.remove(key);
    }
    await Hive.close();
    _conversationsBoxes = {};
    listener!.cancel();
  }

  Box<PpMessage> getConversationBox(String contactNickname) {
    if (_conversationsBoxes[contactNickname] == null) _noBoxException();
    return _conversationsBoxes[contactNickname]!;
  }

  onSendMessage(PpMessage message) async {
    try {
      await _addMessageToHive(message);
      await _sendMessageToContact(message);
    } catch (error) {
      _popup.sww();
    }
  }

  _addMessageToHive(PpMessage message) async {
    final imSender = message.sender == _userService.nickname;
    if (!_contactsService.currentContactNicknames.contains(message.sender) && !imSender) {
      throw Exception('sender not in contacts and im not sender');
    }
    final box = _conversationsBoxes[imSender ? message.receiver : message.sender];
    box != null ? await box.add(message) : _noBoxException();
  }

  _sendMessageToContact(PpMessage message) async {
    await getContactMessagesRef(message.receiver).add(message.asMap);
  }


  _getHiveConversationKey(String contactNickname) {
    return 'conversation_${_userService.nickname}_$contactNickname}';
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

  deleteHiveData() async {
    //TODO: delete when delete account
    await Hive.deleteFromDisk();
  }


}