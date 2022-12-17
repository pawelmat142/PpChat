import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';
import 'package:flutter_chat_app/state/me.dart';

class PpUserService {
  final FirebaseAuth _fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get getUid => _fireAuth.currentUser == null
      ? _handleNoCurrentUser()
      : _fireAuth.currentUser!.uid;

  _handleNoCurrentUser() {
    //todo: handle no current user / clear state data
    NavigationService.popToBlank();
    if (kDebugMode) {
     print('NO CURRENT USER!');
    }
  }


  final _state = getIt.get<States>();

  Me get me => _state.me;
  String get nickname => _state.me.nickname.isNotEmpty ? _state.me.nickname : AuthenticationService.nickname;


  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection(Collections.PpUser);
  DocumentReference<Map<String, dynamic>> get documentRef => _collection.doc(getUid);
  DocumentReference<Map<String, dynamic>> get _privateDocumentRef => documentRef.collection(Collections.PRIVATE).doc(getUid);

  bool initialized = false;

  login({required String nickname}) async {
    await _updateLogged(true);
    me.setNickname(nickname);
    await me.startFirestoreObserver();
    initialized = true;
  }

  logout({bool skipFirestore = false}) async {
    if (!skipFirestore) {
      await _updateLogged(false);
    }
    await me.clear();
    initialized = false;
  }


  Future<PpUser> get userSnapshot async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await documentRef.get();
    return snapshot.exists ? PpUser.fromDB(snapshot) : throw Exception(['NO USER DATA IN FIRESTORE']);
  }


  Future<PpUser?> findByNickname(String nickname) async {
    final snapshot = await _collection.doc(nickname).get();
    return snapshot.exists ? PpUser.fromDB(snapshot) : null;
  }


  Future<void> createNewUser({required String nickname}) async {
    final signature = _collection.doc().id;
    final newUser = PpUser.create(nickname: nickname, uid: getUid, signature: signature);
    await documentRef.set(newUser.asMap);
    await _privateDocumentRef.set(_privateDocumentData);
  }


  deleteUserDocument() async {
    final batch = _firestore.batch();
    batch.delete(_privateDocumentRef);
    batch.delete(documentRef);
    await batch.commit();
  }


  _updateLogged(bool logged) async {
    await documentRef.update({PpUserFields.logged : logged});
    // if ((nickname != null || me.nickname.isNotEmpty) && _fireAuth.currentUser != null) {
    //   await documentRef.update({PpUserFields.logged : logged});
    // }
  }

  get _privateDocumentData => {
    'uid': _fireAuth.currentUser != null
        ? _fireAuth.currentUser!.uid
        : throw Exception('NO USER LOGGED IN'),
    'created': DateTime.now(),
  };
}