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

  String? _nickname;
  String get nickname => _nickname != null ? _nickname! : throw Exception(['NO CURRENT NICKNAME IS SET IN SERVICE']);


  login({required String nickname}) async {
    _nickname = nickname;
    await _updateLogged(true);
  }

  logout() async {
    await _updateLogged(false);
    _nickname = null;
  }


  DocumentReference<Map<String, dynamic>> get _document => _collection.doc(nickname);
  DocumentReference<Map<String, dynamic>> get _privateDocument => _document.collection(Collections.PRIVATE).doc(nickname);


  Future<PpUser> get userSnapshot async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _document.get();
    return snapshot.exists ? PpUser.fromMap(snapshot.data()!) : throw Exception(['NO USER DATA IN FIRESTORE']);
  }


  Future<PpUser?> findByNickname(String nickname) async {
    final snapshot = await _collection.doc(nickname).get();
    return snapshot.exists ? PpUser.fromMap(snapshot.data()!) : null;
  }


  Future<void> createNewUser({required String nickname}) async {
    final newUser = PpUser.create(nickname: nickname);
    final batch = _firestore.batch();
    batch.set(_collection.doc(newUser.nickname), newUser.asMap);
    _nickname = nickname;
    batch.set(_privateDocument, _privateDocumentData);
    _nickname = null;
    await batch.commit();
  }


  deleteUserDocument() async {
    final batch = _firestore.batch();
    batch.delete(_privateDocument);
    batch.delete(_document);
    await batch.commit();
  }


  _updateLogged(bool logged) async {
    if (_nickname != null) {
      await _document.update({PpUserFields.logged : logged});
    }
  }

  get _privateDocumentData => {
    'uid': _fireAuth.currentUser != null ? _fireAuth.currentUser!.uid : throw Exception('NO USER LOGGED IN'),
    'created': DateTime.now(),
  };
}