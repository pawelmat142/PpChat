import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/services/log_service.dart';

class PpNotificationService {

  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();
  final logService = getIt.get<LogService>();

  // will be shown in NotificationsScreen as tile, has own views
  static bool toScreen(PpNotification notification) {
    return [
      PpNotificationTypes.invitation,
      PpNotificationTypes.invitationAcceptance,
      PpNotificationTypes.invitationSelfNotification,
    ].contains(notification.type);
  }


  Notifications get notifications => Notifications.reference;


  markNotificationAsRead(PpNotification notification) async {
    notification.isRead = true;
    notifications.updateOne(notification);
  }


  onRemoveNotification(PpNotification notification) async {
    notifications.deleteOne(notification);
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