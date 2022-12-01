import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/constants/collections.dart';

class LogProcess {

  LogProcess() {
    firstLog();
  }

  final firestore = FirebaseFirestore.instance;

  List<String> logs = [];

  bool saveMode = true;

  firstLog() {
    log('first log - LogProcess');
  }

  log(String log) {
    if (kDebugMode) {
      print(log);
    }
    logs.add('[${DateTime.now().toString()}] - $log');
  }

  save() async {
    if (saveMode) {
      await firestore.collection(Collections.logs).add({'logs': logs});
    }
  }
}