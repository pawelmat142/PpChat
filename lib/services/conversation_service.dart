import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/state/contacts.dart';
import 'package:flutter_chat_app/state/conversations.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';

//TODO: show time on tap message
//TODO: sort messages on view by time
//TODO: implement auto delete
//TODO: configurable time to live
//TODO: implement time to live after read
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
  Contacts get contacts => _state.contacts;

  bool initialized = false;

  login() async {
    initialized = false;
    await _startMessagesObserver();
    initialized = true;
  }

  logout() async {
    if (initialized) {
      await _stopMessagesObserver();
      conversations.clear();
    }
  }

  _startMessagesObserver() async {
    final completer = Completer();
    _messagesObserver ??= messagesCollectionRef.snapshots().listen((event) async {
      logService.log('[MSG] messages observer triggered');

      final Map<String, PpMessage> messages = {};
      for (var doc in event.docs) {
        messages[doc.id] = PpMessage.fromDB(doc);
      }

      if (messages.isNotEmpty) await _resolveMessages(messages);

      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  Map<String, PpMessage> unresolvedMessages = {};

  _resolveMessages(Map<String, PpMessage> messages, {bool skipFlushbar = false}) async {
    logService.log('[MSG] Received ${messages.length} messages.');
    Map<String, PpMessage> resolvedMessages = {};
    unresolvedMessages = {};

    for (var documentId in messages.keys) {

      final senderUid = messages[documentId]!.sender;
      final contactUid = senderUid != States.getUid ? senderUid : messages[documentId]!.receiver;
      if (contacts.containsByUid(contactUid)) {

        final conversation = await conversations.openOrCreate(contactUid: contactUid);
        final msg = messages[documentId]!;
        conversation.addMessage(msg);
        resolvedMessages[documentId] = msg;
      }
      else {
        unresolvedMessages[documentId] = messages[documentId]!;
      }
    }
    if (initialized && !skipFlushbar) PpFlushbar.comingMessages(messages: messages.values.toList());
    await _deleteResolvedMessagesInFs(resolvedMessages.keys.toList());
  }

  _deleteResolvedMessagesInFs(List<String> documentIds) async {
    if (documentIds.isEmpty) return;
    final batch = _firestore.batch();
    for (var docId in documentIds) {
      batch.delete(messagesCollectionRef.doc(docId));
    }
    await batch.commit();
    logService.log('[MSG] ${documentIds.length} messages documents deleted in FS.');
  }


  _stopMessagesObserver() async {
    if (_messagesObserver != null) {
      await _messagesObserver!.cancel();
      _messagesObserver = null;
    }
  }

  resetMessagesObserver() async {
    await _stopMessagesObserver();
    await _startMessagesObserver();
  }

  navigateToConversationView(PpUser contactUser) async {
    await conversations.openOrCreate(contactUid: contactUser.uid);
    ConversationView.navigate(contactUser);
  }

  PpUser? getContactUserByNickname(String contactNickname) {
    return _contactsService.getByNickname(nickname: contactNickname);
  }


  sendMessage({required String message, required PpUser contactUser}) async {
    final msg = PpMessage.create(
        message: message,
        sender: States.getUid!,
        receiver: contactUser.uid
    );
    await contactMessagesCollectionRef(contactUid: contactUser.uid).add(msg.asMap);
    conversations.getByUid(contactUser.uid)?.addMessage(msg);
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
      final docRef = _contactsService.contactNotificationDocRef(contactUid: contactUser.uid);
      batch.set(docRef, notification.asMap);

      logService.log('[MSG] ${querySnapshot.docs.length} unread messages deleted in contact receive box');

      await batch.commit();
      final conversation = conversations.getByUid(contactUser.uid);
      if (conversation != null) conversation.box.clear();
    } catch (error) {
      logService.error(error.toString());
      _popup.sww(text: 'Clear conversation error!');
    }
  }

  resolveConversationClearNotifications(Set<PpNotification> notifications) {
    if (initialized && notifications.isNotEmpty) {
      for (var n in notifications) {
        final contactUser = getContactUserByNickname(n.sender);
        if (contactUser != null) {
          final conversation = conversations.getByUid(contactUser.uid);
          if (conversation != null) conversation.box.clear();
        }
      }
    }
  }

  resolveUnresolvedMessages() {
    if (unresolvedMessages.isNotEmpty) {
      logService.log('[resolveUnresolvedMessages] messages: ${unresolvedMessages.length}');
      _resolveMessages(unresolvedMessages, skipFlushbar: true);
    }
  }

}