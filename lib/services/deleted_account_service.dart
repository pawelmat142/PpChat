import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';

import 'get_it.dart';
import 'log_service.dart';
/*
 * DELETED_ACCOUNT collection management
 * aClient application without admin access has no possibility to remove FireAuth User
 * so deleted account is marked using this collection to prevent log in
 * FireAuth User need to be deleted manually / serverside
 */

class DeletedAccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final logService = getIt.get<LogService>();


  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(Collections.DELETED_ACCOUNTS);

  Future<bool> isDeletedAccount(String nickname) async {
    final snapshot = await collection.doc(nickname).get();
    return snapshot.exists;
  }
}