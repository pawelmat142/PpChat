import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/state/interfaces/data_state_object.dart';

/// Stores Firestore collection state,
/// collection is represented by DataStateObject
/// DataStateObject is synchronized with collection
///
/// each collection change also triggers DataStateObject event
///
abstract class FirestoreCollectionState<T> extends DataStateObject<T> {

  final firestore = FirebaseFirestore.instance;

  FirestoreCollectionState() {
    //i want first data event trigger by firestore object observer
    skipFirstOnChangeEvent = true;
  }

  int counter = 0;

  @override
  addEvent(T item, {bool skipFirestore = false}) {
    if (counter < 5) {
      //get doc ref
      if (skipFirestore) {
        super.addEvent(item);
      } else {
        //add to firestore collection triggers super.add()
        log('[${T.toString()}] add');
        collectionRef.add(toMap(item)).onError((error, stackTrace) => errorHandler(error, stackTrace, 'addEvent'));
      }
      counter++;
    }
  }

  @override
  addsEvent(List<T> items, {bool skipFirestore = false}) {
    if (skipFirestore) {
      super.addsEvent(items);
    } else {
      final batch = firestore.batch();
      for (T item in items) {
        final docId = docIdFromItem(item);
        final docRef = docId.isEmpty ? collectionRef.doc() : collectionRef.doc(docId);
        batch.set(docRef, toMap(item));
      }
      log('[${T.toString()}] adds');
      batch.commit().onError((error, stackTrace) => errorHandler(error, stackTrace, 'addsEvent'));
    }
  }

  @override
  void updateOneEvent(T item, {bool skipFirestore = false}) {
    if (skipFirestore) {
      super.updateOneEvent(item);
    } else {
      final docRef = collectionRef.doc(docIdFromItem(item));
      log('[${T.toString()}] updateOneEvent');
      docRef.set(toMap(item)).onError((error, stackTrace) => errorHandler(error, stackTrace, 'updateOneEvent'));
    }
  }

  @override
  void updateManyEvent(List<T> items, {bool skipFirestore = false}) {
    if (skipFirestore) {
      super.updateManyEvent(items);
    } else {
      final batch = firestore.batch();
      for (var item in items) {
        batch.set(collectionRef.doc(docIdFromItem(item)), toMap(item));
      }
      log('[${T.toString()}] update many: ${items.length}');
      batch.commit().onError((error, stackTrace) => errorHandler(error, stackTrace, 'updateManyEvent'));
    }
  }

  @override
  void deleteOneEvent(T item, {bool skipFirestore = false}) {
    if (skipFirestore) {
      super.deleteOneEvent(item);
    } else {
      final docRef = collectionRef.doc(docIdFromItem(item));
      log('[${T.toString()}] deleteOne');
      docRef.delete().onError((error, stackTrace) => errorHandler(error, stackTrace, 'deleteOneEvent'));
    }
  }


  clearFirestoreCollection() async {
    if (state.isNotEmpty) {
      final batch = firestore.batch();
      for (var item in state) {
        batch.delete(collectionRef.doc(docIdFromItem(item)));
      }
      log('[${T.toString()}] clearFirestoreCollection: ${state.length} items');
      await batch.commit().onError((error, stackTrace) => errorHandler(error, stackTrace, 'clearFirestoreCollection'));
    }
  }

  errorHandler(error, stackTrace, String method) {
    final log = '[${error.runtimeType}] [${T.toString()}] [$method] $error';
    logService.handlePreparedLog(log);
  }


  //override
  Map<String, dynamic> toMap(T item);

  //override
  CollectionReference<Map<String, dynamic>> get collectionRef;

  //override
  Query<Map<String, dynamic>> get collectionQuery;

  //override
  T itemFromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot);

  //override
  T itemFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot);

  //override - leave empty string if docId needs to be random generated
  String docIdFromItem(T item);

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreCollectionObserver;

  bool firstFirestoreObserve = true;

  Future<void> startFirestoreObserver() {
    log('[START] FIRESTORE OBSERVER [${T.toString()}]');
    var completer = Completer();

    _firestoreCollectionObserver = collectionQuery.snapshots().listen((querySnapshot) {
        log('[${T.toString()}] firestore observer');

          setNewStateByQuerySnapshot(querySnapshot);
          if (!completer.isCompleted) completer.complete();
          firstFirestoreObserve = false;

        if (!completer.isCompleted) completer.complete();
    }, onError: (error) {
      errorHandler(error, null, '_firestoreCollectionObserver');
    });
    return completer.future;
  }


  stopFirestoreObserver() async {
    if (_firestoreCollectionObserver != null) {
      log('[STOP] FIRESTORE OBSERVER');
      await _firestoreCollectionObserver!.cancel();
      _firestoreCollectionObserver = null;
    }
  }

  resetFirestoreObserver({bool skipRefresh = false}) async {
    if (_firestoreCollectionObserver != null) {
      await stopFirestoreObserver();
    }
    firstFirestoreObserve = !skipRefresh;
    await startFirestoreObserver();
  }

  setNewStateByQuerySnapshot(QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    final newState = querySnapshot.docs.map((queryDocumentSnapshot) =>
        itemFromQuerySnapshot(queryDocumentSnapshot)).toList();
    setEvent(newState);
  }



  @override
  clear() async {
    await stopFirestoreObserver();
    super.clear();
  }

  killData() {
    clearFirestoreCollection();
    clear();
  }

}