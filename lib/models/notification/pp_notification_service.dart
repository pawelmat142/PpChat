import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
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

  static const channelKey = 'pp_chat';

  bool isAllowed = false;

  // will be shown in NotificationsScreen as tile, has own views
  static bool toScreen(PpNotification notification) {
    return [
      PpNotificationTypes.invitation,
      PpNotificationTypes.invitationAcceptance,
      PpNotificationTypes.invitationSelfNotification,
    ].contains(notification.type);
  }

  Notifications get notifications => Notifications.reference;

  static init() async {
    final service = getIt.get<PpNotificationService>();
    return service.initAwesomeNotifications();
  }

  initAwesomeNotifications() async {
    if (await checkPermission()) {
      ctrl.initialize(
          null, //default icon
          [
            NotificationChannel(
                channelKey: channelKey,
                channelName: 'PpChat notifications',
                channelDescription: 'PpChat notifications',
                channelShowBadge: true,
                // defaultColor: PRIMARY_COLOR,
                ledColor: Colors.white
            )
          ],
          debug: true
      );
    }
  }

  Future<bool> checkPermission() async {
    isAllowed = await ctrl.isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await ctrl.requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  Future<void> refreshBadgeCounter() async {
    if (await checkPermission()) {
      final unreadNotifications = PpNotification.getUnread(Notifications.reference.get);
      logService.log('${unreadNotifications.length} unread notifications');
      return ctrl.setGlobalBadgeCounter(unreadNotifications.length);
    }
  }

  initListeners() async {
    if (await checkPermission()) {
      await ctrl.setListeners(
          onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
          onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
          onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
          onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
      );
    }
  }

  void notifyMessage({required String contactUid}) async {
    if (await checkPermission()) {
      if (!appService.isAppInBackground) {
        if (NavigationService.isUserConversationOpen(contactUid)) return;
        // if (NavigationService.isContactsOpen) return;
      }
      await ctrl.createNotification(content: NotificationContent(
          id: getIdByUid(contactUid), //unique id for each contact
          channelKey: channelKey,
          title: 'You have new message...',
          actionType: ActionType.Default,
          payload: {
            PayloadFields.uid: contactUid,
            PayloadFields.type: PayloadTypes.message
          }
      ));
    }
  }

  void notifyInvitation({required String contactUid}) async {
    if (await checkPermission()) {
      await ctrl.createNotification(content: NotificationContent(
          id: getIdByUid(contactUid),
          //unique id for each contact
          channelKey: channelKey,
          title: 'You have new invitation...',
          actionType: ActionType.Default,
          payload: {
            PayloadFields.uid: contactUid,
            PayloadFields.type: PayloadTypes.invitation
          }
      ));
    }
  }

  void dismiss({required String contactUid}) {
    if (isAllowed) {
      ctrl.dismiss(getIdByUid(contactUid));
    }
  }

  static int getIdByUid(String uid) {
    return int.parse(uid.substring(0, 6), radix: 36);
  }

  markNotificationAsRead(PpNotification notification) async {
    if (isAllowed) {
      notification.isRead = true;
      await notifications.updateOne(notification);
      await refreshBadgeCounter();
    }
  }

  onRemoveNotification(PpNotification notification) async {
    if (isAllowed) {
      await notifications.deleteOne(notification);
      await refreshBadgeCounter();
    }
  }

  onRemoveAll() {
    if (isAllowed) {
      _popup.show('Are you sure?',
          text: 'All notification will be deleted also for senders',
          error: true,
          buttons: [PopupButton('Delete', onPressed: () async {
            _spinner.start();
            await notifications.clearFirestoreCollection();
            await refreshBadgeCounter();
            _spinner.stop();
            PpSnackBar.deleted();
          })]);
    }
  }

}