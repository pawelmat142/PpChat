import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';

class LogProcess {

  LogProcess() {
    firstLog();
  }

  final firestore = FirebaseFirestore.instance;
  final popup = getIt.get<Popup>();

  List<String> logs = [];

  bool saveMode = true;

  String? _context;
  String? _processType;

  setContext(String value) {
    _context = value;
  }

  setProcess(String value) {
    _processType = value;
  }

  setSaveMode(bool mode) {
    saveMode = mode;
  }

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
      Map<String, dynamic> doc = {'atimestamp': DateTime.now(), 'logs': logs};
      if (_context != null) {
        doc['context'] = _context;
      }
      if (_processType != null) {
        doc['process type'] = _processType;
      }
      await firestore.collection(Collections.logs).add(doc);
    }
  }

  errorHandler(error) {
    if (kDebugMode) {
      print(error);
      print(error.runtimeType);
    }
    logs.add('[ERROR] - $error');
    logs.add('error type: ${error.runtimeType.toString()}');
    save();
    popup.sww(text: error.toString());
  }
}