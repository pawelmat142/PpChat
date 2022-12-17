
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';

class ResolveContactDeletedAccountProcess extends LogProcess {

  final String contactNickname;

  ResolveContactDeletedAccountProcess(this.contactNickname) {
    process();
  }

  late WriteBatch batch;

  process() async {
    batch = firestore.batch();

  //  kill hive box
  //  Conversations state update
  //  contacts update
  //

  }
}