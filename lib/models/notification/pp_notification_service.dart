import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/services/log_service.dart';

import '../../services/app_service.dart';
import '../../services/awesome_notifications/notification_controller.dart';
import '../../services/navigation_service.dart';

class PpNotificationService {

  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();
  final logService = getIt.get<LogService>();
  final appService = getIt.get<AppService>();
  final ctrl = AwesomeNotifications();

  get channelKey => NotificationController.notificationsChannelKey;

  // will be shown in NotificationsScreen as tile, has own views
  static bool toScreen(PpNotification notification) {
    return [
      PpNotificationTypes.invitation,
      PpNotificationTypes.invitationAcceptance,
      PpNotificationTypes.invitationSelfNotification,
    ].contains(notification.type);
  }

  Notifications get notifications => Notifications.reference;

  Future<void> setBadgesNumberToUnreadNotificationsNumber() async {
    final unreadNotifications = PpNotification.getUnread(Notifications.reference.get);
    logService.log('${unreadNotifications.length} unread notifications');
    return ctrl.setGlobalBadgeCounter(unreadNotifications.length);
  }

  initListeners() async {
    await ctrl.setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );
  }

  void notifyMessage({required String contactUid}) async {
    if (!appService.isAppInBackground) {
      if (NavigationService.isUserConversationOpen(contactUid)) return;
      // if (NavigationService.isContactsOpen) return;
    }
    await ctrl.createNotification(content: NotificationContent(
        id: NotificationController.getIdByUid(contactUid), //unique id for each contact
        channelKey: channelKey,
        title: 'You have new message...',
        actionType: ActionType.Default,
        payload: {
          PayloadFields.uid: contactUid,
          PayloadFields.type: PayloadTypes.message
        }
    ));
  }

  void notifyInvitation({required String contactUid}) async {
    await ctrl.createNotification(content: NotificationContent(
        id: NotificationController.getIdByUid(contactUid), //unique id for each contact
        channelKey: channelKey,
        title: 'You have new invitation...',
        actionType: ActionType.Default,
        payload: {
          PayloadFields.uid: contactUid,
          PayloadFields.type: PayloadTypes.invitation
        }
    ));
  }

  markNotificationAsRead(PpNotification notification) async {
    notification.isRead = true;
    await notifications.updateOne(notification);
    await setBadgesNumberToUnreadNotificationsNumber();
  }

  onRemoveNotification(PpNotification notification) async {
    await notifications.deleteOne(notification);
    await setBadgesNumberToUnreadNotificationsNumber();
  }

  onRemoveAll() {
    _popup.show('Are you sure?',
        text: 'All notification will be deleted also for senders',
        error: true,
        buttons: [PopupButton('Delete', onPressed: () async {
          _spinner.start();
          await notifications.clearFirestoreCollection();
          await setBadgesNumberToUnreadNotificationsNumber();
          _spinner.stop();
          PpSnackBar.deleted();
        })]);
  }

}