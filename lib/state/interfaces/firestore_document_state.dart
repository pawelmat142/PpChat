import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/state/interfaces/data_state_object.dart';

abstract class FirestoreDocumentState<T> extends DataStateObject<T> {

  final firestore = FirebaseFirestore.instance;

  FirestoreDocumentState() {
    //i want first data event trigger by firestore object observer
    skipFirstOnChangeEvent = true;
  }

  CollectionReference<Map<String, dynamic>> get collectionRef;

  DocumentReference<Map<String, dynamic>> get documentRef;

  List<T> stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot);

  Map<String, dynamic> get stateAsMap;

  StreamSubscription? _firestoreDocumentObserver;

  bool firstFirestoreObserve = true;

  Future<void> startFirestoreObserver() {
    log('[START] [$runtimeType] FIRESTORE OBSERVER');
    var completer = Completer();
    _firestoreDocumentObserver = documentRef.snapshots().listen((documentSnapshot) {

      setEvent(documentSnapshot.exists ? stateFromSnapshot(documentSnapshot) : []);

      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }


  stopFirestoreObserver() async {
    if (_firestoreDocumentObserver != null) {
      log('[STOP] [$runtimeType] FIRESTORE OBSERVER)');
      await _firestoreDocumentObserver!.cancel();
      _firestoreDocumentObserver = null;
    }
  }

  resetFirestoreObserver() async {
    await stopFirestoreObserver();
    await startFirestoreObserver();
  }




  @override
  addEvent(T item, {bool skipFirestore = false}) {
    if (skipFirestore) {
      super.addEvent(item);
    } else {
      log('[${T.toString()}] - add');
      state.add(item);
      documentRef.set(stateAsMap);
    }
  }

  @override
  addsEvent(List<T> items, {bool skipFirestore = false}) {
    if (skipFirestore) {
      super.addsEvent(items);
    } else {
      log('[${T.toString()}] - adds');
      state = get.map((s) => s).toList() + items;
      documentRef.set(stateAsMap);
    }
  }

  @override
  void updateOneEvent(T item) {
    throw Exception('NO IMPLEMENTATION');
  }

  @override
  void deleteOneEvent(T item, {bool skipFirestore = false}) {
    if (skipFirestore) {
      super.deleteOneEvent(item);
    } else {
      final index = get.indexWhere((s) => s == item);
      if (index != -1) {
        log('[${T.toString()}] - deleteOne');
        state.removeAt(index);
        documentRef.set(stateAsMap);
      } else {
        log('[${T.toString()}] - deleteOne: no item');
      }
    }
  }

  void setNewState(List<T> newState) {
    state = [];
    documentRef.set(stateAsMap);
  }

  @override
  clear() async {
    await stopFirestoreObserver();
    super.clear();
  }

  killData() {
    clearFirestoreDocument();
    clear();
  }

  clearFirestoreDocument() async {
    state = [];
    await documentRef.set(stateAsMap);
  }

}



