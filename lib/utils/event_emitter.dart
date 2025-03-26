import 'dart:async';

class EventEmitter {
  static final EventEmitter _instance = EventEmitter._internal();

  factory EventEmitter() {
    return _instance;
  }

  EventEmitter._internal();

  final _eventControllers = <String, StreamController<dynamic>>{};

  StreamSubscription<dynamic> on(String event, Function(dynamic) callback) {
    _eventControllers.putIfAbsent(event, () => StreamController.broadcast());
    return _eventControllers[event]!.stream.listen(callback);
  }

  void emit(String event, [dynamic data]) {
    if (_eventControllers.containsKey(event)) {
      _eventControllers[event]!.add(data);
    }
  }

  void off(String event) {
    _eventControllers[event]?.close();
    _eventControllers.remove(event);
  }

  void dispose() {
    for (var controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();
  }
}
