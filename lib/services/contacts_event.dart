class ContactsEventTypes {
  static const String add = 'add';
  static const String delete = 'delete';
  static const String deleteAccount = 'deleteAccount';
}

class ContactsEvent {
  final String contactNickname;
  final String type;
  final String? firstMessage;
  ContactsEvent({
    required this.contactNickname,
    required this.type,
    this.firstMessage
  });

  static ContactsEvent addContact(String contactNickname, String? firstMessage) {
    return ContactsEvent(contactNickname: contactNickname, type: ContactsEventTypes.add, firstMessage: firstMessage);
  }

  static ContactsEvent deleteContact(String contactNickname) {
    return ContactsEvent(contactNickname: contactNickname, type: ContactsEventTypes.delete);
  }

  static ContactsEvent deleteAccount() {
    return ContactsEvent(contactNickname: ContactsEventTypes.deleteAccount, type: ContactsEventTypes.deleteAccount);
  }
}