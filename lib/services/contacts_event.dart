class ContactsEventTypes {
  static const String add = 'add';
  static const String delete = 'delete';
  static const String deleteAccount = 'deleteAccount';
}

class ContactsEvent {
  final String contactNickname;
  final String type;
  ContactsEvent({
    required this.contactNickname,
    required this.type
  });

  static ContactsEvent addContact(String contactNickname) {
    return ContactsEvent(contactNickname: contactNickname, type: ContactsEventTypes.add);
  }

  static ContactsEvent deleteContact(String contactNickname) {
    return ContactsEvent(contactNickname: contactNickname, type: ContactsEventTypes.delete);
  }

  static ContactsEvent deleteAccount() {
    return ContactsEvent(contactNickname: ContactsEventTypes.deleteAccount, type: ContactsEventTypes.deleteAccount);
  }
}