import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/state/interfaces/firestore_collection_state.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';

class Contacts extends FirestoreCollectionState<PpUser> {


  String? _nickname;
  setNickname(String nickname) => _nickname = nickname;
  String get nickname => _nickname != null ? _nickname! : throw Exception('no nickname - use setNickname first!');

  List<String> _contactNicknames = [];
  setContactNicknames(List<String> list) => _contactNicknames = list;
  List<String> get contactNicknames => _contactNicknames;


  @override
  get collectionRef => firestore.collection(Collections.User);

  @override
  get collectionQuery => collectionRef.where(PpUserFields.nickname, whereIn: contactNicknames);


  @override
  void addEvent(PpUser item, {bool? skipFirestore = false}) {
    super.addEvent(item, skipFirestore: true);
  }

  @override
  addsEvent(List<PpUser> items, {bool? skipFirestore = false}) {
    super.addsEvent(items, skipFirestore: true);
  }

  @override
  void deleteOneEvent(PpUser item, {bool? skipFirestore = false}) {
    contactNicknames.removeAt(contactNicknames.indexWhere((n) => n == item.nickname));
    updateContactNicknames();
  }

  @override
  bool contains(PpUser item) => state.indexWhere((u) => item.nickname == u.nickname) != -1;


  @override
  String docIdFromItem(PpUser item) => item.nickname;

  @override
  Map<String, dynamic> toMap(PpUser item) => item.asMap;

  @override
  int getItemIndex(PpUser item) => state.indexWhere((contact) => contact.nickname == item.nickname);

  @override
  PpUser itemFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) => PpUser.fromDB(documentSnapshot);

  @override
  Future<void> startFirestoreObserver() {
    if (contactNicknames.isEmpty) return Future((){});
    return super.startFirestoreObserver();
  }

  List<String> get nicknames => state.map((user) => user.nickname).toList();

  static const String contactsFieldName = 'contacts';

  DocumentReference<Map<String, dynamic>> get contactNicknamesDocRef => collectionRef.doc(nickname)
    .collection(Collections.CONTACTS).doc(nickname);


  @override
  PpUser itemFromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return PpUser.fromDB(documentSnapshot);
  }

  getBy(String nickname) {
    return state.firstWhere((c) => c.nickname == nickname);
  }

  updateContactNicknames() async {
    //triggers resetFirestoreObserver
    await contactNicknamesDocRef.set({contactsFieldName: contactNicknames.toSet().toList()});
  }
}