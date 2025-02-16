import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_view.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:hive/hive.dart';

class ConversationService {

  static final firestore = FirebaseFirestore.instance;
  final _contactsService = getIt.get<ContactsService>();
  final popup = getIt.get<Popup>();
  final spinner = getIt.get<PpSpinner>();
  final logService = getIt.get<LogService>();
  final notificationService = getIt.get<PpNotificationService>();

  static CollectionReference get messagesCollectionRef => firestore
      .collection(Collections.PpUser).doc(Uid.get)
      .collection(Collections.Messages);

  CollectionReference contactMessagesCollectionRef({required String contactUid}) => firestore
      .collection(Collections.PpUser).doc(contactUid)
      .collection(Collections.Messages);

  StreamSubscription? _messagesObserver;

  // ConversationsOld get conversations => _state.conversations;
  Conversations conversations = Conversations.reference;
  Contacts get contacts => Contacts.reference;

  bool initialized = false;

  login() async {
    initialized = false;
    for (final contact in contacts.get) {
      conversations.openOrCreate(contactUid: contact.uid);
    }
    await startMessagesObserver();
    initialized = true;
  }

  clearConversations() async {
    await conversations.clear();
  }

  startMessagesObserver() async {
    final completer = Completer();
    _messagesObserver ??= messagesCollectionRef.snapshots().listen((event) async {
      logService.log('[MSG] messages observer triggered');

      final Map<String, PpMessage> messages = {};
      for (var doc in event.docs) {
        messages[doc.id] = PpMessage.fromDB(doc);
      }
      if (messages.isNotEmpty) {
        await _resolveMessages(messages);
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    logService.log('[START] [Messages] firestore collection observer');
    return completer.future;
  }

  Map<String, PpMessage> unresolvedMessages = {};

  _resolveMessages(Map<String, PpMessage> messages, { bool skipNotification = false }) async {
    logService.log('[MSG] Received ${messages.length} messages.');
    Map<String, PpMessage> resolvedMessages = {};
    unresolvedMessages = {};

    for (var documentId in messages.keys) {

      final PpMessage message = messages[documentId]!;

      final sender = message.sender;

      final contactUid = sender != Uid.get ? sender : message.receiver;

      if (contacts.containsByUid(contactUid)) {

        if (message.message == '') {
          continue;
        }
        final conversation = await conversations.openOrCreate(contactUid: contactUid);
        conversation.addMessageToHive(message);
        resolvedMessages[documentId] = message;
      }
      else {
        unresolvedMessages[documentId] = messages[documentId]!;
      }
    }

    notificationService.notifyMessage(contactUid: messages.values.first.sender);

    await _deleteResolvedMessagesInFs(resolvedMessages.keys.toList());
  }

  _deleteResolvedMessagesInFs(List<String> documentIds) async {
    if (documentIds.isEmpty) return;
    final batch = firestore.batch();
    for (var docId in documentIds) {
      batch.delete(messagesCollectionRef.doc(docId));
    }
    await batch.commit();
    logService.log('[MSG] ${documentIds.length} messages documents deleted in FS.');
  }


  stopMessagesObserver() async {
    if (_messagesObserver != null) {
      logService.log('[STOP] [Messages] firestore collection observer');
      await _messagesObserver!.cancel();
      _messagesObserver = null;
    }
  }

  resetMessagesObserver() async {
    await stopMessagesObserver();
    await startMessagesObserver();
  }

  navigateToConversationView(PpUser contactUser) async {
    logService.log('[MSG] Navigation to conversation view ${contactUser.uid}');
    final Conversation conversation = await conversations.openOrCreate(contactUid: contactUser.uid);
    await conversation.refreshPublicKey();
    Navigator.pushNamed(NavigationService.context, ConversationView.id, arguments: contactUser);
  }

  PpUser? getContactUserByUid(String contactUid) {
    return _contactsService.getByUid(uid: contactUid);
  }

  resolveUnresolvedMessages() {
    if (unresolvedMessages.isNotEmpty) {
      logService.log('[resolveUnresolvedMessages] messages: ${unresolvedMessages.length}');
      _resolveMessages(unresolvedMessages, skipNotification: true);
    }
  }

  onLockConversation(String uid) async {
    await Future.delayed(const Duration(milliseconds: 10));
    popup.show('Are you sure?',
        text: 'Messages data will be lost also on the other side!',
        buttons: [PopupButton('Clear and lock', onPressed: () async {
          spinner.start();
          final conversation = Conversations.reference.getByUid(uid)!;
          await conversation.lockMock();
          spinner.stop();
        })]);
  }

  onUnlock(String contactUid) async {
    final conversation = Conversations.reference.getByUid(contactUid)!;
    final mockMessage = conversation.box!.values.first;
    if (mockMessage.sender != Uid.get!) return;
    await Future.delayed(const Duration(milliseconds: 10));
    popup.show('Unlock conversation?', error: true,
        buttons: [PopupButton('Unlock', onPressed: () async {
          spinner.start();
          await conversation.clearMock();
          spinner.stop();
        })]
    );
  }

  onClearConversation(String uid) async {
    await Future.delayed(const Duration(milliseconds: 100));
    popup.show('Are you sure?',
        text: 'Messages data will be lost also on the other side!',
        buttons: [PopupButton('Clear', onPressed: () async {
          spinner.start();
          final conversation = Conversations.reference.getByUid(uid)!;
          await conversation.clearMock();
          spinner.stop();
        })]
    );
  }

  onDeleteContact(PpUser contactUser) async {
    final contactsService = getIt.get<ContactsService>();
    await contactsService.deleteContact(contactUser.uid);
  }

  isConversationLocked(PpUser contactUser) {
    return conversations.getByUid(contactUser.nickname)!.isLocked;
  }

  markAsRead(Box<PpMessage> box) {
    Future.delayed(Duration.zero, () {
      Map<dynamic, PpMessage> result = {};
      int markedAsRead = 0;

      for (var key in box.keys) {
        PpMessage? message = box.get(key);
        if (message != null && !message.isRead) {
          message.readTimestamp = DateTime.now();
          markedAsRead++;
        }
        result[key] = message!;
      }

      if (markedAsRead > 0) {
        box.putAll(result);
        logService.log('[MSG] $markedAsRead messages marked as read');
      }
    });
  }

  contactExists(String contactUid) {
    return _contactsService.contactExists(contactUid);
  }

}