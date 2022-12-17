import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/state/interfaces/firestore_collection_state.dart';

class Notifications extends FirestoreCollectionState<PpNotification> {

  String? _nickname;
  setNickname(String nickname) => _nickname = nickname;
  String get nickname => _nickname != null ? _nickname! : throw Exception('no nickname - use setNickname first!');


  @override
  CollectionReference<Map<String, dynamic>> get collectionRef => firestore
      .collection(Collections.PpUser).doc(nickname)
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
    _nickname = null;
    super.clear();
  }

  bool imSender(PpNotification item) => item.sender == nickname;

  @override
  String docIdFromItem(PpNotification item) => imSender(item) ? item.receiver : item.sender;

  getOne({required String sender}) {
    final index = get.indexWhere((n) => n.sender == sender);
    return index == -1 ? null : get[index];
  }
  
  List<PpNotification> get toScreen => get.where((n) => PpNotificationService.toScreen(n)).toList();
  Stream<List<PpNotification>> get toScreenStream => stream
      .map((list) => list.where((n) => PpNotificationService.toScreen(n)).toList());

}