import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/process/accept_invitation_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/services/log_service.dart';

class InvitationService {

  final _firestore = FirebaseFirestore.instance;

  final _state = getIt.get<States>();
  final _contactsService = getIt.get<ContactsService>();
  final logService = getIt.get<LogService>();


  onAcceptInvitation(PpNotification notification, {bool pop = true}) async {
    final process = AcceptInvitationProcess(invitation: notification);
    await process.process();
  }


  resolveInvitationAcceptances(Set<PpNotification> notifications) async {
    if (notifications.isNotEmpty) {
      final newContactNicknames = notifications.map((n) => n.sender).toList();
      _state.contactNicknames.addsEvent(newContactNicknames);
    }
  }


  resolveContactDeletedNotifications(Set<PpNotification> notifications) async {
    //todo: if on contact / conversation view - navigate to home/contacts and show popup
    if (notifications.isNotEmpty) {
      final nicknamesToDelete = notifications.map((n) => n.sender).toList();
      final newState = _state.contactNicknames.get
          .where((n) => !nicknamesToDelete.contains(n))
          .toList();
      _state.contactNicknames.setNewState(newState);
    }
  }

  onCancelSentInvitation(PpNotification notification) async {
    try {
      logService.log('[START] [CANCEL SENT INVITATION]');
      if (notification.type != PpNotificationTypes.invitationSelfNotification) {
        throw Exception('[CANCEL SENT INVITATION] NOT INVITATION SELF ACCEPTANCE');
      }
      final batch = _firestore.batch();
      batch.delete(_state.notifications.collectionRef.doc(notification.documentId));
      batch.delete(_contactsService.contactNotificationDocRef(contactUid: notification.documentId));
      await batch.commit();
      PpFlushbar.invitationDeleted();
      logService.log('[STOP] [CANCEL SENT INVITATION]');
    } catch (error) {
      logService.errorHandler(error);
    }
  }

  onRejectReceivedInvitation(PpNotification notification) async {
    try {
      logService.log('[START] [REJECT RECEIVED INVITATION]');
      if (notification.type != PpNotificationTypes.invitation) {
        throw Exception('[REJECT RECEIVED INVITATION] NOT INVITATION');
      }
      final batch = _firestore.batch();
      batch.delete(_state.notifications.collectionRef.doc(notification.documentId));
      batch.delete(_contactsService.contactNotificationDocRef(contactUid: notification.documentId));
      await batch.commit();
      PpFlushbar.invitationDeleted();
      logService.log('[STOP] [REJECT RECEIVED INVITATION]');
    } catch (error) {
      logService.errorHandler(error);
    }
  }

  isInvitationReceived(String nickname) {
    for (var notification in _state.notifications.get) {
      if (notification.sender == nickname && notification.type == PpNotificationTypes.invitation) {
        return true;
      }
    }
    return false;
  }

  isInvitationSent(String nickname) {
    for (var notification in _state.notifications.get) {
      if (notification.receiver == nickname && notification.type == PpNotificationTypes.invitationSelfNotification) {
        return true;
      }
    }
    return false;
  }
}