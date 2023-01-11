import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/crypto/hive_rsa_pair.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_mock.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/message_cleaner.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class Conversation {

  final conversationService = getIt.get<ConversationService>();
  final messageCleaner = MessageCleaner();

  Conversation({required this.contactUid});

  final String contactUid;
  Box<PpMessage>? box;

  bool get isOpen => box != null && box!.isOpen;

  Iterable<PpMessage> get values => box == null ? [] : box!.values;

  List<PpMessage> get messages => values.toList();
  List<String> get messagesTxt => values.map((m) => m.message).toList();

  bool _isMocked = false;
  bool get isLocked => values.length == 1 && values.first.message == MessageMock.TYPE_LOCK;

  late RSAPublicKey contactPublicKey;
  late PpUser contactUser;
  late ConversationSettings settings;
  late CollectionReference contactMessagesCollectionRef;

  open({bool temporary = false}) async {
    box = await Hive.openBox(hiveKey(contactUid: contactUid));
    if (!temporary) {
      _initializeContactPublicKey();
    }
    await _initializeSettings();
    contactMessagesCollectionRef = conversationService.contactMessagesCollectionRef(contactUid: contactUid);
    await messageCleaner.init(contactUid: contactUid);
  }

  _initializeContactPublicKey() {
    final contactsService = getIt.get<ContactsService>();
    contactUser = contactsService.getByUid(uid: contactUid)!;
    contactPublicKey = HiveRsaPair.stringToRsaPublic(contactUser.publicKeyAsString);
  }

  _initializeSettings() async {
    final conversationSettingsService = getIt.get<ConversationSettingsService>();
    settings = await conversationSettingsService
        .getSettings(contactUid: contactUid);
  }


  sendMessage(String content) async {
    final PpMessage encryptedMessage = PpMessage.create(
        message: encrypt(content, contactPublicKey),
        sender: Uid.get!,
        receiver: contactUid,
        timeToLive: settings.timeToLiveInMinutes,
        timeToLiveAfterRead: settings.timeToLiveAfterReadInMinutes
    );
    await contactMessagesCollectionRef.add(encryptedMessage.asMap);

    final PpMessage messageForMe = PpMessage.create(
        message: content,
        sender: Uid.get!,
        receiver: contactUid,
        timeToLive: settings.timeToLiveInMinutes,
        timeToLiveAfterRead: settings.timeToLiveAfterReadInMinutes
    );
    await addMessageToHive(messageForMe);
  }

  ///MOCK MESSAGES
  ///are not encrypted!
  clearMock() async {
    await _sendMockMessage(MessageMock.TYPE_CLEAR);
  }

  lockMock() async {
    await _sendMockMessage(MessageMock.TYPE_LOCK);
  }

  _sendMockMessage(String mockType) async {
    final mockMessage = PpMessage.create(
        message: mockType,
        sender: Uid.get!,
        receiver: contactUser.uid,
        timeToLive: -1,
        timeToLiveAfterRead: -1);
    await contactMessagesCollectionRef.add(mockMessage.asMap);
    await addMessageToHive(mockMessage);
  }


  addMessageToHive(PpMessage message) async {
    if (message.isMock) {
      _isMocked = true;
      await box!.clear();
    } else if (_isMocked) {
      if (isLocked) return;
      _isMocked = false;
      await box!.clear();
    }
    await box!.add(message);
  }


  static hiveKey({required contactUid}) {
    return 'conversation_${Uid.get}_$contactUid';
  }

  static create({required String contactUid}) {
    final conversation = Conversation(contactUid: contactUid);
    log('created for uid: $contactUid');
    return conversation;
  }











  static log(String txt) {
    Future.delayed(Duration.zero, () {
      final logService = getIt.get<LogService>();
      logService.log('[Conversation] $txt');
    });
  }



}

