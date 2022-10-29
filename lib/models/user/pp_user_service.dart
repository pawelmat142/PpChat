import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';

class PpUserService {
  final FirebaseAuth _fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late CollectionReference<Map<String, dynamic>> _collection;

  PpUserService() {
    _collection = _firestore.collection(Collections.User);
  }

  DocumentReference<Map<String, dynamic>> get _document => _collection.doc(user.nickname);
  DocumentReference<Map<String, dynamic>> get _privateDocument => _document.collection(Collections.PRIVATE).doc(user.nickname);

  PpUser? _user;
  PpUser get user => _user != null ? _user! : throw Exception(['NO CURRENT USER IN SERVICE']);


  Future<PpUser> get userSnapshot async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _document.get();
    return snapshot.exists ? PpUser.fromMap(snapshot.data()!) : throw Exception(['NO USER DATA IN FIRESTORE']);
  }


  Future<PpUser?> findByNickname(String nickname) async {
    final snapshot = await _collection.doc(nickname).get();
    return snapshot.exists ? PpUser.fromMap(snapshot.data()!) : null;
  }


  Future<void> createNewUser({required String nickname}) async {
    _user = PpUser.create(nickname: nickname);
    final batch = _firestore.batch();
    batch.set(_document, user.asMap);
    batch.set(_privateDocument, _privateDocumentData);
    await batch.commit();
  }


  deleteUserDocument() async {
    final batch = _firestore.batch();
    batch.delete(_privateDocument);
    batch.delete(_document);
    await batch.commit();
  }


  updateLogged(bool logged) async {
    await _document.update({PpUserFields.logged : logged});
  }


  get _privateDocumentData => {
    'uid': _fireAuth.currentUser!.uid,
    'created': DateTime.now(),
  };
}