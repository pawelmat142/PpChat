import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/state/interfaces/firestore_collection_state.dart';
import 'package:flutter_chat_app/state/states.dart';

class Notifications extends FirestoreCollectionState<PpNotification> {

  static String get getUid => States.getUid;


  @override
  CollectionReference<Map<String, dynamic>> get collectionRef => firestore
      .collection(Collections.PpUser).doc(getUid)
      .collection(Collections.NOTIFICATIONS);

  @override
  Query<Map<String, dynamic>> get collectionQuery => collectionRef;

  @override
  Map<String, dynamic> toMap(PpNotification item) => item.asMap;

  @override
  PpNotification itemFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return PpNotification.fromDB(documentSnapshot);
  }

  @override
  PpNotification itemFromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return PpNotification.fromDB(documentSnapshot);
  }

  @override
  int getItemIndex(PpNotification item) => state.indexWhere((notification) => notification.sender == item.sender);

  @override
  clear() {
    super.clear();
  }

  @override
  String docIdFromItem(PpNotification item) => item.documentId;

  getOne({required String sender}) {
    final index = get.indexWhere((n) => n.sender == sender);
    return index == -1 ? null : get[index];
  }
  
  List<PpNotification> get toScreen => get.where((n) => PpNotificationService.toScreen(n)).toList();
  Stream<List<PpNotification>> get toScreenStream => stream
      .map((list) => list.where((n) => PpNotificationService.toScreen(n)).toList());

}