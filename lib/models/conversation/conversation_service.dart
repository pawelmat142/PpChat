import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_mock.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_view.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';

//TODO: implement auto delete
//TODO: configurable time to live
//TODO: implement time to live after read
//TODO: show unread messages on tile
class ConversationService {

  final _firestore = FirebaseFirestore.instance;
  final _contactsService = getIt.get<ContactsService>();
  final popup = getIt.get<Popup>();
  final spinner = getIt.get<PpSpinner>();
  final logService = getIt.get<LogService>();

  CollectionReference get messagesCollectionRef => _firestore
      .collection(Collections.PpUser).doc(Uid.get)
      .collection(Collections.Messages);

  CollectionReference contactMessagesCollectionRef({required String contactUid}) => _firestore
      .collection(Collections.PpUser).doc(contactUid)
      .collection(Collections.Messages);

  StreamSubscription? _messagesObserver;

  // ConversationsOld get conversations => _state.conversations;
  Conversations conversations = Conversations.reference;
  Contacts get contacts => Contacts.reference;

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
      final contactUid = senderUid != Uid.get ? senderUid : messages[documentId]!.receiver;
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


  sendMessage({required String message, required PpUser contactUser, bool isMock = false}) async {
    final msg = PpMessage.create(
        message: message,
        sender: Uid.get!,
        receiver: contactUser.uid,
        timeToLive: isMock ? -1 : 0
    );
    await contactMessagesCollectionRef(contactUid: contactUser.uid).add(msg.asMap);
    conversations.getByUid(contactUser.uid)?.addMessage(msg);
  }


  clearConversation(PpUser contactUser) async {
    sendMessage(
        message: MessageMock.TYPE_CLEAR,
        contactUser: contactUser,
        isMock: true
    );
  }

  lockConversation(PpUser contactUser) async {
    sendMessage(
        message: MessageMock.TYPE_LOCK,
        contactUser: contactUser,
        isMock: true
    );
  }

  resolveUnresolvedMessages() {
    if (unresolvedMessages.isNotEmpty) {
      logService.log('[resolveUnresolvedMessages] messages: ${unresolvedMessages.length}');
      _resolveMessages(unresolvedMessages, skipFlushbar: true);
    }
  }

  onLockConversation(String uid) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final contactUser = _contactsService.getByUid(uid: uid)!;
    popup.show('Are you sure?',
        text: 'Messages data will be lost also on the other side!',
        buttons: [PopupButton('Clear and lock', onPressed: () async {
          spinner.start();
          await lockConversation(contactUser);
          spinner.stop();
        })]);
  }

  onUnlock(String uid) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final contactUser = _contactsService.getByUid(uid: uid)!;
    popup.show('Unlock conversation?', error: true, buttons: [PopupButton('Unlock', onPressed: () {
      clearConversation(contactUser);
    })]);
  }

  onClearConversation(String uid) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final contactUser = _contactsService.getByUid(uid: uid)!;
    popup.show('Are you sure?',
        text: 'Messages data will be lost also on the other side!',
        buttons: [PopupButton('Clear', onPressed: () async {
          spinner.start();
          await clearConversation(contactUser);
          spinner.stop();
        })]);
  }

  onDeleteContact(PpUser contactUser) async {
    final contactsService = getIt.get<ContactsService>();
    await contactsService.onDeleteContact(contactUser.uid);
  }

  isConversationLocked(PpUser contactUser) {
    return conversations.getByUid(contactUser.nickname)!.isLocked;
  }


}