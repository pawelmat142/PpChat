import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';

class ContactsService {

  static const String contactsFieldName = 'contacts';

  final _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();

  DocumentReference<Map<String, dynamic>> get _contactsListRef {
    return _firestore.collection(Collections.User)
        .doc(_userService.nickname)
        .collection(Collections.CONTACTS)
        .doc(_userService.nickname);
  }

  //CURRENT VALUE
  List<String> _current = [];
  List<String> get currentContacts => _current;


  login() async {
    final response = await _contactsListRef.get();
    if (response.exists) {
      final result = response.get(contactsFieldName);
      if (result is List<String>) {
        _current = result;
      }
    }
  }

  logout() {
    _current = [];
  }

  addNewContact({required String nickname}) async {
    final newList = _current.map((contact) => contact).toList();
    newList.add(nickname);
    try {
      await _firestore
          .collection(Collections.User)
          .doc(_userService.nickname)
          .collection(Collections.CONTACTS)
          .doc(_userService.nickname).set({contactsFieldName: newList});
      _current = newList;
    } catch (error) {
      print(error);
    }
  }

}