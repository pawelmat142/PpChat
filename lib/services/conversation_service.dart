import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_screens/conversation_view.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/state/conversations.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';


class ConversationService {

  final _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();
  final _contactsService = getIt.get<ContactsService>();
  final _popup = getIt.get<Popup>();
  final _state = getIt.get<States>();
  final logService = getIt.get<LogService>();

  CollectionReference get messagesCollectionRef => _firestore
      .collection(Collections.PpUser).doc(States.getUid)
      .collection(Collections.Messages);

  CollectionReference contactMessagesCollectionRef({required String contactUid}) => _firestore
      .collection(Collections.PpUser).doc(contactUid)
      .collection(Collections.Messages);

  StreamSubscription? _messagesObserver;

  Conversations get conversations => _state.conversations;

  bool initialized = false;

  login() async {
    initialized = false;
    await _startMessagesObserver();
    initialized = true;
  }

  logout() async {
    await _stopMessagesObserver();
    conversations.clear();
  }

  _startMessagesObserver() async {
    final completer = Completer();
    _messagesObserver ??= messagesCollectionRef.snapshots().listen((event) async {

      logService.log('[MSG] messages observer triggered');
      final List<String> comingMessagesDocIds = [];

      final comingMessages = event.docChanges
          .where((change) => DocumentChangeType.added == change.type)
          .map((change) {
            comingMessagesDocIds.add(change.doc.id);
            return PpMessage.fromDB(change.doc);
          }).toList();

      if (comingMessagesDocIds.length != comingMessages.length) throw Exception('[MSG] error');
      await _resolveComingMessages(comingMessages);
      await _deleteResolvedMessagesInFs(comingMessagesDocIds);

      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }



  _stopMessagesObserver() {
    if (_messagesObserver != null) {
      _messagesObserver!.cancel();
      _messagesObserver = null;
    }
  }

  _resolveComingMessages(List<PpMessage> messages) async {
    if (messages.isEmpty) return;
    logService.log('[MSG] Received ${messages.length} messages.');
    for (var message in messages) {
      final contactNickname = message.sender;
      await conversations.openOrCreate(contactNickname: contactNickname);
      conversations.getByNickname(contactNickname)?.addMessage(message);
    }
    if (initialized) PpFlushbar.comingMessages(messages: messages);
  }

  _deleteResolvedMessagesInFs(List<String> docIds) async {
    if (docIds.isEmpty) return;
    final batch = _firestore.batch();
    for (var docId in docIds) {
      batch.delete(messagesCollectionRef.doc(docId));
    }
    await batch.commit();
    logService.log('[MSG] ${docIds.length} messages documents deleted in FS.');
  }


  navigateToConversationView(PpUser contactUser) async {
    await conversations.openOrCreate(contactNickname: contactUser.nickname);
    ConversationView.navigate(contactUser);
  }

  getContactUserByNickname(String contactNickname) {
    return _contactsService.getBy(nickname: contactNickname);
  }


  sendMessage({required String message, required PpUser contactUser}) async {
    final msg = PpMessage.create(
        message: message,
        sender: _userService.nickname,
        receiver: contactUser.nickname
    );
    await contactMessagesCollectionRef(contactUid: contactUser.uid).add(msg.asMap);
    conversations.getByNickname(contactUser.nickname)?.addMessage(msg);
  }


  clearConversation(PpUser contactUser) async {
    //TODO: security rule to delete doc in contact messages collection
    try {
      final batch = _firestore.batch();

      //get unread messages in contact receive box
      final querySnapshot = await contactMessagesCollectionRef(contactUid: contactUser.uid)
          .where(PpMessageFields.sender, isEqualTo: _userService.nickname)
          .get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      //send notification
      final notification = PpNotification.createConversationClear(
          documentId: _state.me.signature,
          sender: _userService.nickname,
          receiver: contactUser.nickname
      );
      //todo: refactor method to pass PpUser object instead of nickname
      final docRef = _contactsService.contactNotificationDocRef(contactUid: contactUser.uid);
      batch.set(docRef, notification.asMap);

      logService.log('[MSG] ${querySnapshot.docs.length} unread messages deleted in contact receive box');

      await batch.commit();
      final conversation = conversations.getByNickname(contactUser.nickname);
      if (conversation != null) conversation.clearBox();
    } catch (error) {
      logService.error(error.toString());
      _popup.sww(text: 'Clear conversation error!');
    }
  }

  resolveConversationClearNotifications(Set<PpNotification> notifications) {
    if (initialized && notifications.isNotEmpty) {
      for (var n in notifications) {
        final conversation = conversations.getByNickname(n.sender);
        if (conversation != null) conversation.clearBox();
      }
    }
  }

}