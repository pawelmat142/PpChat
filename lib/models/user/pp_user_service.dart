import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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


  final _state = getIt.get<States>();

  Me get me => _state.me;
  String get nickname => _state.me.nickname.isNotEmpty ? _state.me.nickname : AuthenticationService.nickname;

  String _myDocId = '';
  String get myDocId {
    if (_myDocId.isNotEmpty) return _myDocId;
    if (me.isNotEmpty) return me.get[0].docId;
    throw Exception('no doc id available');
  }

  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection(Collections.PpUser);
  DocumentReference<Map<String, dynamic>> get documentRef => _collection.doc(myDocId);
  DocumentReference<Map<String, dynamic>> get _privateDocumentRef => documentRef.collection(Collections.PRIVATE).doc(myDocId);

  DocumentReference getUserDocRef({required String nickname}) => _collection.doc(nickname);

  bool initialized = false;

  login({required String nickname}) async {
    authValidate(where: 'userService');
    await _updateLogged(true, nickname: nickname);
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


  authValidate({String? where}) {
    if (_fireAuth.currentUser == null) {
      NavigationService.popToBlank();
      throw Exception('auth guard: $where');
    }
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
    _myDocId = _collection.doc().id;
    final newUser = PpUser.create(nickname: nickname, docId: _myDocId);
    await getUserDocRef(nickname: myDocId).set(newUser.asMap);
    await _privateDocumentRef.set(_privateDocumentData);
    _myDocId = '';
  }


  deleteUserDocument() async {
    final batch = _firestore.batch();
    batch.delete(_privateDocumentRef);
    batch.delete(documentRef);
    await batch.commit();
  }


  _updateLogged(bool logged, {String? nickname}) async {
    if ((nickname != null || me.nickname.isNotEmpty) && _fireAuth.currentUser != null) {
      await getUserDocRef(nickname: nickname ?? me.nickname).update({PpUserFields.logged : logged});
    }
  }

  get _privateDocumentData => {
    'uid': _fireAuth.currentUser != null
        ? _fireAuth.currentUser!.uid
        : throw Exception('NO USER LOGGED IN'),
    'created': DateTime.now(),
  };
}