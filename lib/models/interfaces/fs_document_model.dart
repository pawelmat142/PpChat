import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';

abstract class FsDocumentModel<T> with ChangeNotifier {

  final logService = getIt.get<LogService>();
  log(String txt) => logService.log(txt);
  error(String txt) => logService.error(txt);

  final firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get documentRef;

  Map<String, dynamic> get stateAsMap;

  T stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot);





  T? _state;
  T get get => _state!;
  bool get isNotEmpty => _state != null;

  Future<void> set(T item) async {
    _state = item;
    await documentRef.set(stateAsMap);
    log('[set] [$runtimeType]');
  }

  Future<void> clear() async {
    _state = null;
    notifyListeners();
    log('[clear] [$runtimeType]');
  }

  Future<void> clearFirestoreDocument() async {
    _state = null;
    await documentRef.set(stateAsMap);
    log('[clearFirestoreDocument] [$runtimeType]');
  }


  ///FIRESTORE DOCUMENT OBSERVER

  StreamSubscription? _firestoreDocumentObserver;

  Future<void> startFirestoreObserver() {
    log('[START] [$runtimeType] firestore document observer');
    var completer = Completer();
    _firestoreDocumentObserver = documentRef.snapshots().listen((documentSnapshot) {
      log('[$runtimeType] document observer triggered');

      _state = documentSnapshot.exists ? stateFromSnapshot(documentSnapshot) : null;
      notifyListeners();

      if (!completer.isCompleted) completer.complete();

    }, onError: (error) {
      errorHandler(error, null, '_firestoreDocumentObserver');
    });
    return completer.future;
  }

  stopFirestoreObserver() async {
    if (_firestoreDocumentObserver != null) {
      log('[STOP] [$runtimeType] firestore document observer');
      await _firestoreDocumentObserver!.cancel();
      _firestoreDocumentObserver = null;
    }
  }

  resetFirestoreObserver() async {
    await stopFirestoreObserver();
    await startFirestoreObserver();
  }

  pauseFirestoreDocument() async {
    if (_firestoreDocumentObserver != null) {
      _firestoreDocumentObserver!.pause();
    }
  }

  resumeFirestoreDocument() async {
    if (_firestoreDocumentObserver != null) {
      _firestoreDocumentObserver!.resume();
    }
  }



  errorHandler(error, stackTrace, String method) {
    final log = '[ERROR] [$method] [${error.runtimeType}] [${T.toString()}] $error';
    logService.handlePreparedLog(log);
  }

}