import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/services/get_it.dart';

class LogService extends LogProcess {

  static addLog(String txt) {
    getIt.get<LogService>().log(txt);
  }

  error(String logTxt) {
    log('[ERROR] - $logTxt');
  }

}