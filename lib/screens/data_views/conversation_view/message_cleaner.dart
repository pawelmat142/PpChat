import 'dart:async';

import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:hive/hive.dart';

class MessageCleaner {

  final conversationService = getIt.get<ConversationService>();
  final logService = getIt.get<LogService>();
  log(String txt) => logService.log('[MessageCleaner] $contactUid - $txt');

  static const timerPeriod = 1;

  late String contactUid;
  late Box<PpMessage> box;

  late Timer _periodicTimer;
  late List<Timer> _messageTimers;

  bool initialized = false;

  init({required String contactUid, required Box<PpMessage> box}) async {
    if (initialized) return;
    this.contactUid = contactUid;
    this.box = box;
    log('initialization');
    await _cleanExpiredMessages();
    _messageTimers = [];
    _setMessageTimersIfExpiresSoon();
    _startPeriodicTimer();
    initialized = true;
  }

  dispose() async {
    if (!initialized) return;
    log('dispose');
    _stopPeriodicTimer();
    _cancelMessageTimers();
    initialized = false;
  }

  _startPeriodicTimer() {
    _periodicTimer = Timer.periodic(const Duration(minutes: timerPeriod), (timer) {
      log('periodic timer triggered');
      _setMessageTimersIfExpiresSoon();
    });
    log('periodic timer started');
  }

  _stopPeriodicTimer() {
    if (_periodicTimer.isActive) {
      _periodicTimer.cancel();
      log('periodic timer stopped - active: ${_periodicTimer.isActive}');
    }
  }

  _cancelMessageTimers() {
    for (var messageTimer in _messageTimers) {
      messageTimer.cancel();
    }
    _messageTimers = [];
  }

  _setMessageTimersIfExpiresSoon() async {
    _cancelMessageTimers();
    for (final key in box.keys) {
      _checkSingleMessage(key);
    }
  }

  _checkSingleMessage(key) {
    final m = box.get(key)!;
    final durationOne = _getDurationToExpireIfSoon(m);
    final durationTwo = _getDurationToExpireAfterReadIfSoon(m);
    final duration = _getShorterDuration(durationOne, durationTwo);

    if (duration != null) {
      log('message with key: $key will expire in ${duration.inSeconds} seconds...');
      final messageTimer = Timer(duration, () => _cleanOne(key));
      _messageTimers.add(messageTimer);
    }
  }

  Duration _getDurationToExpireIfSoon(PpMessage m) {
    final duration = m.timestamp.add(Duration(minutes: m.timeToLive)).difference(DateTime.now());
    return duration.inSeconds > 0 && duration.inMinutes <= timerPeriod ? duration : Duration.zero;
  }

  Duration _getDurationToExpireAfterReadIfSoon(PpMessage m) {
    final duration = m.readTimestamp.add(Duration(minutes: m.timeToLiveAfterRead)).difference(DateTime.now());
    return m.isRead && duration.inSeconds > 0 && duration.inMinutes < timerPeriod ? duration : Duration.zero;
  }

  Duration? _getShorterDuration(Duration a, Duration b) {
    final aPositive = a.inSeconds > 0;
    final bPositive = b.inSeconds > 0;
    if (aPositive && !bPositive) return a;
    if (!aPositive && bPositive) return b;
    if (aPositive && bPositive) return a.compareTo(b) < 0 ? a : b;
    return null;
  }

  _cleanExpiredMessages() async {
    if (box.isNotEmpty) {
      final Iterable expiredMessagesKeys = box.keys
          .where((key) => box.get(key)!.isExpired);
      if (expiredMessagesKeys.isNotEmpty) {
        await box.deleteAll(expiredMessagesKeys);
        log('${expiredMessagesKeys.length} expired messages deleted');
      }
    }
    await box.compact();
  }

  _cleanOne(msgKey) async {
    box.delete(msgKey);
    log('message with key: $msgKey deleted now');
  }

}