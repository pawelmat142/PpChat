import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/services/local_notifications/local_notifications_service.dart';
import 'package:flutter_chat_app/services/uid.dart';

class ResolveNotificationsProcess extends LogProcess {

  final _invitationService = getIt.get<InvitationService>();
  final localNotificationsService = getIt.get<LocalNotificationsService>();

  Me get me => Me.reference;

  ResolveNotificationsProcess(this.notifications, {this.skipFlushbar = false});

  final List<PpNotification> notifications;
  final bool skipFlushbar;

  final Set<PpNotification> invitationAcceptances = {};
  final Set<PpNotification> contactDeletedNotifications = {};

  final Set<PpNotification> notificationsToFlush = {};

  late WriteBatch batch;

  process() async {
    try {
      log('[START] ResolveNotificationsProcess');
      setContext(me.nickname);
      setProcess('ResolveNotificationsProcess');
      batch = firestore.batch();

      _prepareNotifications();

      _triggerResolves();

      await batch.commit();

      if (!skipFlushbar) _flushbar();

      log('[STOP] ResolveNotificationsProcess');
    } catch (error) {
      errorHandler(error);
    }
  }


  _prepareNotifications() {
    for (var notification in notifications) {
      if (!notification.isResolved || !notification.isFlushed) {
        switch (notification.type) {

          case PpNotificationTypes.invitation:
            notification.isFlushed = true;
            batch.set(documentReference(notification), notification.asMap);
            notificationsToFlush.add(notification);
            break;

          case PpNotificationTypes.invitationAcceptance:
            invitationAcceptances.add(notification);
            notification.isResolved = true;
            notification.isFlushed = true;
            batch.set(documentReference(notification), notification.asMap);
            notificationsToFlush.add(notification);
            break;

          case PpNotificationTypes.contactDeletedNotification:
            contactDeletedNotifications.add(notification);
            batch.delete(documentReference(notification));
            break;

        }
      }
    }
    if (invitationAcceptances.isNotEmpty) log('${invitationAcceptances.length} invitation acceptances to resolve');
    if (contactDeletedNotifications.isNotEmpty) log('${contactDeletedNotifications.length} contacts to delete');
    if (notificationsToFlush.isNotEmpty) log('${notificationsToFlush.length} notifications to flush');
  }


  _triggerResolves() async {
    //ANY ACTION HERE SHOULD NOT MODIFY NOTIFICATIONS COLLECTION!
    //IT WILL BE DONE IN _prepareBatch() AND commit()

    _invitationService.resolveInvitationAcceptances(invitationAcceptances);

    _invitationService.resolveContactDeletedNotifications(contactDeletedNotifications);
  }

  _flushbar() {
    if (notificationsToFlush.length == 1) {
      final notification = notificationsToFlush.first;
      switch (notification.type) {
        case PpNotificationTypes.invitation:
          localNotificationsService.invitationNotification(uid: notification.documentId);
          break;
        case PpNotificationTypes.invitationAcceptance:
          PpSnackBar.invitationAcceptances();
          break;
      }
    }
  }


  DocumentReference documentReference(PpNotification notification) => firestore
      .collection(Collections.PpUser).doc(Uid.get)
      .collection(Collections.NOTIFICATIONS).doc(notification.documentId);

  String documentId(PpNotification notification) => imSender(notification) ? notification.receiver : notification.sender;

  bool imSender(PpNotification notification) => notification.sender == me.nickname;

}
