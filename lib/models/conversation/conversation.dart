import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_mock.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:hive/hive.dart';

class Conversation {
  Conversation({required this.contactUid, required this.box});

  final String contactUid;
  final Box<PpMessage> box;

  bool get isOpen => box.isOpen;

  List<PpMessage> get messages => box.values.toList();
  List<String> get messagesTxt => box.values.map((m) => m.message).toList();

  //TODO: use compact more often


  open() async {
    await Hive.openBox(hiveKey(contactUid: contactUid));
  }

  bool _isMocked = false;
  bool get isLocked => box.values.length == 1 && box.values.first.message == MessageMock.TYPE_LOCK;


  addMessage(PpMessage message) async {
    if (message.isMock) {
      _isMocked = true;
      await box.clear();
    } else if (_isMocked) {
      if (isLocked) return;
      _isMocked = false;
      await box.clear();
    }
    await box.add(message);
  }


  static hiveKey({required contactUid}) {
    return 'conversation_${Uid.get}_$contactUid';
  }

  static create({required String contactUid}) async {
    final box = await Hive.openBox<PpMessage>(hiveKey(contactUid: contactUid));
    return Conversation(contactUid: contactUid, box: box);
  }

}

