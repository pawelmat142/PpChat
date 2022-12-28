import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/process/log_process.dart';

class LogService extends LogProcess {

  error(String logTxt) {
    if (kDebugMode) {
      log('[ERROR] - $logTxt');
    }
  }

  @override
  log(String log) {
    if (kDebugMode) {
      super.log(log);
    }
  }

}