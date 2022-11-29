class ContactsEventTypes {
  static const String add = 'add';
  static const String remove = 'remove';
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

  static ContactsEvent removeContact(String contactNickname) {
    return ContactsEvent(contactNickname: contactNickname, type: ContactsEventTypes.remove);
  }
}