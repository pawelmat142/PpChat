import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';

abstract class DataStateObject<T> {

  @protected
  late List<T> state = [];

  DataStateObject({List<T>? initialValue}) {
    log('[$T] [DataStateObject] constructor');
    state = initialValue ?? [];
  }

  final logService = getIt.get<LogService>();
  log(String txt) => logService.log(txt);
  error(String txt) => logService.error(txt);


  void addEvent(T item) {
    log('[$T] Add item: ${item.toString()}.');
    state.add(item);
    onChangeEvent();
  }

  void addsEvent(List<T> items) {
    log('[$T] Adds ${items.length} items.');
    setEvent(state  + items);
  }

  void setEvent(List<T> items) {
    log('[$T] Sets ${items.length} items.');
    state = items;
    onChangeEvent();
  }

  void updateOneEvent(T item) {
    final index = getItemIndex(item);
    if (index != -1) {
      log('[$T] Update item index: $index.');
      state[index] = item;
      onChangeEvent();
    } else {
      log('[$T] Tried to update item.');
    }
  }

  void updateManyEvent(List<T> items) {
    try {
      if (items.isEmpty) throw Exception();
      for (var item in items) {
        final index = getItemIndex(item);
        if (index == -1) throw Exception();
        state[index] = item;
      }
      log('[$T] Update ${items.length} items');
      onChangeEvent();
    } catch (error) {
      log('[$T] Tried to update ${items.length} items.');
    }
  }

  void deleteOneEvent(T item) {
    final index = getItemIndex(item);
    if (index != -1) {
      log('[$T] Delete item index: $index');
      state.removeAt(index);
      onChangeEvent();
    } else {
      log('[${item.runtimeType}] Tried delete item');
    }
  }

  //override
  int getItemIndex(T item);

  T popEvent() {
    final last = state.removeLast();
    log('Items left: ${state.length}, Removed item: ${last.toString()}');
    onChangeEvent();
    return last;
  }

  List<T> get get => state;
  int get length => state.length;
  bool get isEmpty => state.isEmpty;
  bool get isNotEmpty => state.isNotEmpty;

  bool contains(T item) => state.contains(item);

  clear() => setEvent([]);

  //REACTIVE

  bool reactiveModeOn = true;
  bool skipFirstOnChangeEvent = false;
  bool isFirstOnChangeEvent = true;


  @protected
  onChangeEvent() async {
    if (!(isFirstOnChangeEvent && skipFirstOnChangeEvent) && reactiveModeOn) {
      if (_controller.hasListener) {
        _controller.sink.add(state);
        log('[$runtimeType] onChangeEvent data propagated');
      }
    }
    isFirstOnChangeEvent = false;
  }


  final StreamController<List<T>> _controller = StreamController.broadcast();
  Stream<List<T>> get stream => _controller.stream;

}