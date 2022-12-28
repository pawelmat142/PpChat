import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';

abstract class FsCollectionModel<T> with ChangeNotifier {

  final logService = getIt.get<LogService>();
  log(String txt) => logService.log(txt);
  error(String txt) => logService.error(txt);

  final firestore = FirebaseFirestore.instance;


  /// OVERRIDE
  Query<Map<String, dynamic>> get collectionQuery;

  Map<String, dynamic> toMap(T item);

  T itemFromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot);

  String docIdFromItem(T item);




  /// STATE

  List<T> _state = [];
  List<T> get get => _state;

  bool get isNotEmpty => _state.isNotEmpty;
  bool get isEmpty => _state.isEmpty;


  clear() {
    _state = [];
    notifyListeners();
  }








  /// FIRESTORE OBSERVER

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreCollectionObserver;

  Future<void> startFirestoreObserver() {
    log('[START] [$runtimeType] firestore collection observer');
    var completer = Completer();
    _firestoreCollectionObserver = collectionQuery.snapshots().listen((querySnapshot) {

      setNewStateByQuerySnapshot(querySnapshot);
      if (!completer.isCompleted) completer.complete();

    }, onError: (error) {
      errorHandler(error, null, '_firestoreCollectionObserver');
    });
    return completer.future;
  }

  setNewStateByQuerySnapshot(QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    _state = querySnapshot.docs.map((queryDocumentSnapshot) =>
        itemFromQuerySnapshot(queryDocumentSnapshot)).toList();
    notifyListeners();
  }

  stopFirestoreObserver() async {
    if (_firestoreCollectionObserver != null) {
      log('[STOP] [$runtimeType] firestore collection observer');
      await _firestoreCollectionObserver!.cancel();
      _firestoreCollectionObserver = null;
    }
  }

  resetFirestoreObserver() async {
    await stopFirestoreObserver();
    await startFirestoreObserver();
  }

  pauseFirestoreDocument() async {
    if (_firestoreCollectionObserver != null) {
      _firestoreCollectionObserver!.pause();
    }
  }

  resumeFirestoreDocument() async {
    if (_firestoreCollectionObserver != null) {
      _firestoreCollectionObserver!.resume();
    }
  }











  errorHandler(error, stackTrace, String method) {
    final log = '[ERROR] [$method] [${error.runtimeType}] [${T.toString()}] $error';
    logService.handlePreparedLog(log);
  }
}