import 'dart:async';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/process/resolve_notifications_process.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/state/notifications.dart';
import 'package:flutter_chat_app/services/log_service.dart';

class PpNotificationService {

  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();
  final _state = getIt.get<States>();
  final logService = getIt.get<LogService>();

  // will be shown in NotificationsScreen as tile, has own views
  static bool toScreen(PpNotification notification) {
    return [
      PpNotificationTypes.invitation,
      PpNotificationTypes.invitationAcceptance,
      PpNotificationTypes.invitationSelfNotification,
    ].contains(notification.type);
  }


  Notifications get notifications => _state.notifications;

  StreamSubscription? _notificationsListener;

  bool initialized = false;

  Future<void> login() async {
    await notifications.startFirestoreObserver();
    final process = ResolveNotificationsProcess(notifications.get);
    await process.process();
    startNotificationsListener();
    initialized = true;
  }

  logout() {
    if (initialized) {
      notifications.clear();
      if (_notificationsListener != null) {
        _notificationsListener!.cancel();
        _notificationsListener = null;
      }
      initialized = false;
    }
  }

  startNotificationsListener() async {
    _notificationsListener ??= notifications.stream.listen((event) async {
      final process = ResolveNotificationsProcess(event);
      await process.process();
    }, onError: listenerErrorHandler);
  }

  stopNotificationsListener() async {
    if (_notificationsListener != null) {
      _notificationsListener!.cancel();
      _notificationsListener = null;
    }
  }

  listenerErrorHandler(error) {
    logService.errorHandler(error, label: '_notificationsListener');
  }

  markNotificationAsRead(PpNotification notification) async {
    notification.isRead = true;
    notifications.updateOneEvent(notification);
  }


  onRemoveNotification(PpNotification notification) async {
    notifications.deleteOneEvent(notification);
  }

  onRemoveAll() {
    _popup.show('Are you sure?',
        text: 'All notification will be deleted also for senders',
        error: true,
        buttons: [PopupButton('Delete', onPressed: () async {
          _spinner.start();
          notifications.clearFirestoreCollection();
          _spinner.stop();
          PpFlushbar.notificationsDeleted();
        })]);
  }

}