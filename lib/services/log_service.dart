import 'package:flutter_chat_app/process/log_process.dart';

class LogService extends LogProcess {

  error(String logTxt) {
    log('[ERROR] - $logTxt');
  }

}