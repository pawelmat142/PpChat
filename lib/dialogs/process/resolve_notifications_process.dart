import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/state/states.dart';

class ResolveNotificationsProcess extends LogProcess {

  final _state = getIt.get<States>();
  final _invitationService = getIt.get<InvitationService>();
  final _conversationService = getIt.get<ConversationService>();

  ResolveNotificationsProcess(this.notifications, {this.skipFlushbar = false});

  final List<PpNotification> notifications;
  final bool skipFlushbar;

  final Set<PpNotification> invitationAcceptances = {};
  final Set<PpNotification> conversationClearNotifications = {};
  final Set<PpNotification> contactDeletedNotifications = {};

  final Set<PpNotification> notificationsToFlush = {};

  late WriteBatch batch;

  process() async {
    try {
      log('[START] ResolveNotificationsProcess');
      setContext('ResolveNotificationsProcess');
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

          case PpNotificationTypes.conversationClearNotification:
            conversationClearNotifications.add(notification);
            batch.delete(documentReference(notification));
            break;

          case PpNotificationTypes.contactDeletedNotification:
            conversationClearNotifications.add(notification);
            contactDeletedNotifications.add(notification);
            batch.delete(documentReference(notification));
            break;

        }
      }
    }
    if (invitationAcceptances.isNotEmpty) log('${invitationAcceptances.length} invitation acceptances to resolve');
    if (conversationClearNotifications.isNotEmpty) log('${conversationClearNotifications.length} conversations to clear');
    if (contactDeletedNotifications.isNotEmpty) log('${contactDeletedNotifications.length} contacts to delete');
    if (notificationsToFlush.isNotEmpty) log('${notificationsToFlush.length} notifications to flush');
    log('prepared');
  }


  _triggerResolves() async {
    //ANY ACTION HERE SHOULD NOT MODIFY NOTIFICATIONS COLLECTION!
    //IT WILL BE DONE IN _prepareBatch() AND commit()

    _invitationService.resolveInvitationAcceptances(invitationAcceptances);

    _conversationService.resolveConversationClearNotifications(conversationClearNotifications);

    _invitationService.resolveContactDeletedNotifications(contactDeletedNotifications);
  }

  _flushbar() {
    if (notificationsToFlush.length == 1) {
      final notification = notificationsToFlush.first;
      switch (notification.type) {
        case PpNotificationTypes.invitation:
          PpFlushbar.invitationNotification(notification);
          break;
        case PpNotificationTypes.invitationAcceptance:
          PpFlushbar.invitationAcceptances(notifications: [notification]);
          break;
      }
    }
    else if (notificationsToFlush.isNotEmpty) {
      PpFlushbar.multipleNotifications(value: notificationsToFlush.length);
    }
  }


  DocumentReference documentReference(PpNotification notification) => firestore
      .collection(Collections.PpUser).doc(States.getUid)
      .collection(Collections.NOTIFICATIONS).doc(notification.documentId);

  String documentId(PpNotification notification) => imSender(notification) ? notification.receiver : notification.sender;

  bool imSender(PpNotification notification) => notification.sender == _state.me.nickname;

}
