import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/notification/notifications.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

class InvitationService {

  final _firestore = FirebaseFirestore.instance;

  final _contactsService = getIt.get<ContactsService>();
  final _conversationSettingsService = getIt.get<ConversationSettingsService>();
  final logService = getIt.get<LogService>();

  final ContactUids contactUids = ContactUids.reference;
  final Notifications notifications = Notifications.reference;


  resolveInvitationAcceptances(Set<PpNotification> invitationAcceptances) async {
    if (invitationAcceptances.isEmpty) {
      return;
    }
    final newContactUids = invitationAcceptances.map((n) => n.documentId).toSet().toList();
    contactUids.addMany(newContactUids);
  }

  resolveContactDeletedNotifications(Set<PpNotification> notifications) async {
    if (notifications.isNotEmpty) {
      final contactUidsToDelete = notifications.map((n) => n.documentId).toList();
      for (final contactUid in contactUidsToDelete) {
        NavigationService.popHomeIfAnyUserView(uid: contactUid);
        await _conversationSettingsService.fullDeleteConversation(contactUid: contactUid);
      }
      final newState = contactUids.get
          .where((n) => !contactUidsToDelete.contains(n))
          .toList();
      contactUids.set(newState);
    }
  }

  cancelSentInvitation(PpNotification notification) async {
    try {
      logService.log('[START] [CANCEL SENT INVITATION]');
      if (notification.type != PpNotificationTypes.invitationSelfNotification) {
        throw Exception('[CANCEL SENT INVITATION] NOT INVITATION SELF ACCEPTANCE');
      }
      final batch = _firestore.batch();
      batch.delete(notifications.collectionRef.doc(notification.documentId));
      batch.delete(_contactsService.contactNotificationDocRef(contactUid: notification.documentId));
      await batch.commit();
      PpSnackBar.invitationDeleted();
      logService.log('[STOP] [CANCEL SENT INVITATION]');
    } catch (error) {
      logService.errorHandler(error);
    }
  }

  rejectReceivedInvitation(PpNotification notification) async {
    try {
      logService.log('[START] [REJECT RECEIVED INVITATION]');
      if (notification.type != PpNotificationTypes.invitation) {
        throw Exception('[REJECT RECEIVED INVITATION] NOT INVITATION');
      }
      final batch = _firestore.batch();
      batch.delete(notifications.collectionRef.doc(notification.documentId));
      batch.delete(_contactsService.contactNotificationDocRef(contactUid: notification.documentId));
      await batch.commit();
      PpSnackBar.invitationDeleted();
      logService.log('[STOP] [REJECT RECEIVED INVITATION]');
    } catch (error) {
      logService.errorHandler(error);
    }
  }

  isInvitationReceived(String nickname) {
    for (var notification in notifications.get) {
      if (notification.sender == nickname && notification.type == PpNotificationTypes.invitation) {
        return true;
      }
    }
    return false;
  }

  isInvitationSent(String nickname) {
    for (var notification in notifications.get) {
      if (notification.receiver == nickname && notification.type == PpNotificationTypes.invitationSelfNotification) {
        return true;
      }
    }
    return false;
  }
}