import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/process/resolve_notifications_process.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/interfaces/fs_collection_state.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:provider/provider.dart';

class Notifications extends FsCollectionModel<PpNotification> {

  static Notifications get reference => Provider.of<Notifications>(NavigationService.context, listen: false);

  bool initialized = false;

  start() async {
    await startFirestoreObserver();
    final process = ResolveNotificationsProcess(get);
    await process.process();
    addListener(_notificationsListener);
    initialized = true;
  }

  stopNotificationsListener() {
    removeListener(_notificationsListener);
  }

  _notificationsListener() async {
    final process = ResolveNotificationsProcess(get);
    await process.process();
  }




  @override
  CollectionReference<Map<String, dynamic>> get collectionRef => firestore
      .collection(Collections.PpUser).doc(Uid.get)
      .collection(Collections.NOTIFICATIONS);

  @override
  String docIdFromItem(PpNotification item) {
    return item.documentId;
  }

  @override
  PpNotification itemFromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return PpNotification.fromDB(documentSnapshot);
  }

  @override
  Map<String, dynamic> toMap(PpNotification item) {
    return item.asMap;
  }

  @override
  int indexFromItem(PpNotification item) {
    return get.indexWhere((i) => i.documentId == item.documentId);
  }


}