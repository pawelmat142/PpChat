import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:hive/hive.dart';

class Conversation {
  Conversation({required this.contactUid, required this.box});

  final String contactUid;
  final Box<PpMessage> box;

  bool get isOpen => box.isOpen;

  closeBox() => box.close();

  clearBox() => box.clear();

  Future<void> killBox() async {
    if (box.isOpen) await box.deleteFromDisk();
  }


  //TODO: use compact more often


  open() async {
    await Hive.openBox(hiveKey(contactUid: contactUid));
  }

  addMessage(PpMessage message) async {
    await box.add(message);
  }


  static hiveKey({required contactUid}) {
    return 'conversation_${States.getUid}_$contactUid';
  }

  static create({required String contactUid}) async {
    final box = await Hive.openBox<PpMessage>(hiveKey(contactUid: contactUid));
    return Conversation(contactUid: contactUid, box: box);
  }


}

