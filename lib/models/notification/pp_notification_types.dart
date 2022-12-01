abstract class PpNotificationTypes {
  static const invitation = 'invitation';
  static const invitationSelfNotification = 'invitationSelfNotification';
  static const invitationAcceptance = 'invitationAcceptance';
  static const contactDeletedNotification = 'contactDeletedNotification';
  static const conversationClearNotification = 'conversationClearNotification';
  static const message = 'message';

  static const List<String> list = [
    invitation,
    invitationSelfNotification,
    invitationAcceptance,
    contactDeletedNotification,
    conversationClearNotification,
    message
  ];
}