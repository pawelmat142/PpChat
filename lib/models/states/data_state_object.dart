import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';


//TODO: prepare version for single non list object
//TODO: prepare version with HIVE integration
//TODO: prepare version with firestore reactive integration

class DataStateObject<T> {

  late List<T> _state = [];

  DataStateObject({List<T>? intitialValue}) {
    print('DataStateObject - constructor');
    _state = intitialValue ?? [];
  }

  final _logService = getIt.get<LogService>();
  log(String txt) => _logService.log('[DataStateObject] - $txt');
  error(String txt) => _logService.error('[DataStateObject] - $txt');

  List<T> get state => _state;

  void add(T item) {
    log('Pushing item: ${item.toString()}');
    _state.add(item);
    _event();
  }

  void adds(List<T> items) {
    log('adds ${items.length} items');
    set(_state  + items);
  }

  void set(List<T> items) {
    log('Setting ${items.length} items');
    _state = items;
    _event();
  }

  T pop() {
    final last = _state.removeLast();
    log('Items left: ${_state.length}, Removed item: ${last.toString()}');
    _event();
    return last;
  }

  int get length => _state.length;

  //REACTIVE


  Function? onChange;

  _onChange() {
    print('_onChange');
    if (onChange != null) {
      log('onChange triggered');
      onChange!();
      log('onChange finished');
    }
  }

  _event() async {
    log('_event');
    _onChange();
    // _controller.sink.add(dataList);
    // await _triggerOutsideEvents();
  }



  //
  // final StreamController<List<T>> _controller = StreamController.broadcast();
  // Stream<List<T>> get stream => _controller.stream;
  //
  // List<Function> _outsideEvents = [];
  //
  //
  // _triggerOutsideEvents() {
  //   log('${_outsideEvents.length} events to trigger!');
  //   if (_outsideEvents.isNotEmpty) {
  //     var i = 0;
  //     _outsideEvents.asMap().values.forEach((e) async {
  //       log('Triggering event ${(i++).toString()}');
  //       await e();
  //     });
  //   }
  // }
  //
  // reset() {
  //   dataList = [];
  //   _event();
  //   _removeEvents();
  // }
  //
  // addEvent(Function event) {
  //   _outsideEvents.add(event);
  // }
  //
  // killData() {
  //   reset();
  //   _controller.close();
  // }
  //
  // _removeEvents() {
  //   _outsideEvents = [];
  // }

}