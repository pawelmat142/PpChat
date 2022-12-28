import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/state/contact_uids.dart';
import 'package:flutter_chat_app/state/interfaces/firestore_collection_state.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';
import 'package:flutter_chat_app/state/states.dart';

class ContactsOld extends FirestoreCollectionState<PpUser> {

  static get getUid => States.getUid;

  List<String> _contactUids = [];
  setContactUids(List<String> list) => _contactUids = list;
  List<String> get contactUids => _contactUids;


  @override
  get collectionRef => firestore.collection(Collections.PpUser);

  @override
  get collectionQuery => collectionRef.where(PpUserFields.uid, whereIn: contactUids);


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
    contactUids.removeAt(contactUids.indexWhere((n) => n == item.uid));
    updateContactUids();
  }

  @override
  bool contains(PpUser item) => state.indexWhere((u) => item.uid == u.uid) != -1;

  bool containsByUid(String uid) => state.indexWhere((u) => uid == u.uid) != -1;


  @override
  String docIdFromItem(PpUser item) => item.uid;

  @override
  Map<String, dynamic> toMap(PpUser item) => item.asMap;

  @override
  int getItemIndex(PpUser item) => state.indexWhere((contact) => contact.uid == item.uid);

  @override
  PpUser itemFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) => PpUser.fromDB(documentSnapshot);

  @override
  Future<void> startFirestoreObserver() {
    if (contactUids.isEmpty) return Future((){});
    return super.startFirestoreObserver();
  }

  List<String> get nicknames => state.map((user) => user.nickname).toList();
  List<String> get uids => state.map((user) => user.uid).toList();

  DocumentReference<Map<String, dynamic>> get contactUidsDocumentRef => collectionRef.doc(States.getUid)
    .collection(Collections.CONTACTS).doc(States.getUid);


  @override
  PpUser itemFromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return PpUser.fromDB(documentSnapshot);
  }

  PpUser? getByNickname(String nickname) {
    final index = state.indexWhere((s) => s.nickname == nickname);
    return index != -1 ? state[index] : null;
  }

  PpUser? getByUid(String uid) {
    final index = state.indexWhere((s) => s.uid == uid);
    return index != -1 ? state[index] : null;
  }

  getBy(String nickname) {
    return state.firstWhere((c) => c.nickname == nickname);
  }

  updateContactUids() async {
    //triggers resetFirestoreObserver
    await contactUidsDocumentRef.set({ContactUidsOld.contactUidsFieldName: contactUids.toSet().toList()});
  }
}