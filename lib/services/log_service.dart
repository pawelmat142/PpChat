import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';

class LogService extends LogProcess {

  @override
  firstLog() {
    if (kDebugMode) {
      log('[*START LOG SERVICE*]');
    }
    setProcess('GLOBAL PROCESS');
  }

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

  @override
  errorHandler(error) {
    if (kDebugMode) {
      super.errorHandler(error);
    }
  }

}