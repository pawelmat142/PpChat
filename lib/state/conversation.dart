import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_mock.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:hive/hive.dart';

class Conversation {
  Conversation({required this.contactUid, required this.box});

  final String contactUid;
  final Box<PpMessage> box;

  bool get isOpen => box.isOpen;


  Future<void> killBox() async {
    if (box.isOpen) await box.deleteFromDisk();
  }

  List<PpMessage> get messages => box.values.toList();
  List<String> get messagesTxt => box.values.map((m) => m.message).toList();

  //TODO: use compact more often


  open() async {
    await Hive.openBox(hiveKey(contactUid: contactUid));
  }

  addMessage(PpMessage message) async {
    if (_isMocked) {
      _isMocked = false;
      await box.clear();
    }
    await box.add(message);
  }


  static hiveKey({required contactUid}) {
    return 'conversation_${States.getUid}_$contactUid';
  }

  static create({required String contactUid}) async {
    final box = await Hive.openBox<PpMessage>(hiveKey(contactUid: contactUid));
    return Conversation(contactUid: contactUid, box: box);
  }

  bool _isMocked = false;

  mock(String mockType, {required String sender}) async {
    switch(mockType) {

      case ConversationMock.CONVERSATION_MOCK_TYPE_CLEAR:
        await box.clear();
        box.add(PpMessage.create(
            message: ConversationMock.CONVERSATION_MOCK_TYPE_CLEAR,
            sender: sender,
            receiver: ConversationMock.IS_MOCK_RECEIVER));
        _isMocked = true;
        break;

      case ConversationMock.CONVERSATION_MOCK_TYPE_LOCK:
        break;
      default: throw Exception('WRONG CONVERSATION MOCK');
    }

  }
}

