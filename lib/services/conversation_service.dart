import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/contacts_event.dart';
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

  StreamSubscription? _messagesListener;
  StreamSubscription? _contactsEventListener;

  // < nickname, hiveBox>
  Map<String, Box<PpMessage>> _conversationsBoxes = {};

  //filled by notification service when login
  List<String> nicknamesToConversationClear = [];

  bool initialized = false;

  login() async {
    // open hive conversation boxes
    _userService.authValidate(where: 'conversation service');
    for (var contactNickname in _contactsService.currentContactNicknames) {
      await _addConversationEvent(contactNickname);
    }

    // listen for contacts list modification
    _contactsEventListener = _contactsService.contactsEventStream.listen((event) {
      switch (event.type) {
        case ContactsEventTypes.add:
          _addConversationEvent(event.contactNickname, firstMessage: event.firstMessage);
          break;
        case ContactsEventTypes.delete:
          _deleteConversationEvent(event.contactNickname);
          break;
        case ContactsEventTypes.deleteAccount:
          _deleteAccountEvent();
          break;
      }
    }, onError: (error) {
      print('in _contactsEventListener error:');
      print(error);
    });

    // listen for coming messages - add to hive and delete from firestore
    _messagesListener = messagesCollectionRef.snapshots().listen((event) async {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          await _addMessageToHive(PpMessage.fromDB(change.doc));
          await change.doc.reference.delete();
        }
      }
    }, onError: (error) {
      print('in _messagesListener error:');
      print(error);
    });
    initialized = true;
    await resolveConversationClearForReceiver(nicknamesToConversationClear);
    print('conversation service initialized');
  }


  logout() async {
    initialized = false;
    await _contactsEventListener!.cancel();
    for (var box in _conversationsBoxes.values) {
      await box.close();
    }
    await Hive.close();
    _conversationsBoxes = {};
    _messagesListener!.cancel();
    print('conversation service loogged out');
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

  _addConversationEvent(String contactNickname, {String? firstMessage}) async {
    //triggered by contacts service
    final box = await Hive.openBox<PpMessage>(_getHiveConversationKey(contactNickname));
    _conversationsBoxes[contactNickname] = box;

    if (firstMessage != null) {
      final message = PpMessage.create(message: firstMessage, sender: contactNickname, receiver: _userService.nickname);
      _addMessageToHiveDelayed(message, 500);
    }
  }

  _deleteConversationEvent(String contactNickname) async {
    //triggered by contacts service
    await _deleteUnreadSentMessagesIfExists(contactNickname);
    final box = getConversationBox(contactNickname);
    await box.deleteFromDisk();
    _conversationsBoxes.remove(contactNickname);
  }

  _deleteAccountEvent() async {
    //TODO: BUG: delete account bug
    await Hive.deleteFromDisk();
  }

  _addMessageToHiveDelayed(PpMessage message, int delay) async {
    await Future.delayed(Duration(milliseconds: delay));
    _addMessageToHive(message);
  }

  _addMessageToHive(PpMessage message) async {
    final imSender = message.sender == _userService.nickname;
    if (!_contactsService.currentContactNicknames.contains(message.sender) && !imSender) {
      //to do: delete those messages?
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

  clearConversation(String contactNickname) async {
    await _clearConversation(contactNickname);
    await _deleteUnreadSentMessagesIfExists(contactNickname);
    await _sendConversationClearNotification(contactNickname);
  }

  _clearConversation(String contactNickname) async {
    final box = getConversationBox(contactNickname);
    await box.clear();
  }

  _deleteUnreadSentMessagesIfExists(String contactNickname) async {
    //TODO: security rule to delete doc in contact messages collection
    final querySnapshot = await getContactMessagesRef(contactNickname)
        .where(PpMessageFields.sender, isEqualTo: _userService.nickname)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  _sendConversationClearNotification(String contactNickname) async {
    final notification = PpNotification.createConversationClear(sender: _userService.nickname, receiver: contactNickname);
    await _firestore.collection(Collections.User).doc(notification.receiver)
        .collection(Collections.NOTIFICATIONS).doc(notification.sender).set(notification.asMap);
  }

  resolveConversationClearForReceiver(List<String> nicknames) async {
    if (initialized) {
      for (var contactNickname in nicknames) {
        _clearConversation(contactNickname);
        _clearConversationEvent();
      }
      nicknamesToConversationClear = [];
    } else {
      nicknamesToConversationClear = nicknames;
    }
  }

  final StreamController<void> _clearConversationEventController = StreamController.broadcast();
  get clearConversationEventStream => _clearConversationEventController.stream;
  _clearConversationEvent() => _clearConversationEventController.sink.add(null);

}