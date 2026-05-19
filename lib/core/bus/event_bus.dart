import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final bus = EventBus();

mixin EventBusCubitMixin<S> on Cubit<S> {
  final List<StreamSubscription> _subs = [];

  void subscribe<T>(void Function(T event) onData) =>
      _subs.add(bus.on<T>().listen(onData));

/*  @override
  Future<void> close() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    return super.close();
  }*/
}

mixin EventBusStateMixin<S extends StatefulWidget> on State<S> {
  final List<StreamSubscription> _subs = [];

  void subscribe<T>(void Function(T event) onData) =>
      _subs.add(bus.on<T>().listen(onData));

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }
}
