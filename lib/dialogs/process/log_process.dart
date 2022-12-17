import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';

class LogProcess {

  final _spinner = getIt.get<PpSpinner>();

  LogProcess() {
    firstLog();
  }

  final firestore = FirebaseFirestore.instance;
  final popup = getIt.get<Popup>();

  List<String> logs = [];

  bool saveMode = true;

  String _context = 'unset';
  String _processType = 'unset';

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
    log('first log');
  }

  log(String log) {
    if (kDebugMode) {
      print(log);
    }
    logs.add('[${DateTime.now().toString()}] [$_processType] $log');
  }

  save() async {
    if (saveMode) {
      Map<String, dynamic> document = {'aTimestamp': DateTime.now(), 'logs': logs};
      document['context'] = _context;
      document['process type'] = _processType;
      await firestore.collection(Collections.logs).add(document);
    }
  }

  errorHandler(error, {String? label}) {
    _spinner.stop();
    if (kDebugMode) {
      print(error);
      print(error.runtimeType);
    }
    if (label == null) {
      logs.add('[ERROR] [${error.runtimeType.toString()}] $error');
    } else {
      logs.add('[ERROR] [$label] [${error.runtimeType.toString()}] $error');
    }
    save();
    popup.sww(text: error.toString());
  }

  handlePreparedLog(String text) {
    logs.add(text);
    save();
    popup.sww(text: text);
  }
}