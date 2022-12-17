import 'package:flutter_chat_app/state/interfaces/data_state_object.dart';

class SingleDataStateObject<T> extends DataStateObject<T> {

  //zrobic jako osoby core - nie extension

  @override
  void setEvent(List<T> items) {}

  @override
  void addsEvent(List<T> items) {}

  @override
  popEvent() {return state.first;}



  bool get exists => state.length == 1;

  // T get get => exists ? state.first : throw Exception('SingleDataStateObject not exists');

  put(T item) => state = [item];

  @override
  int getItemIndex(T item) {
    throw UnimplementedError();
  }

}