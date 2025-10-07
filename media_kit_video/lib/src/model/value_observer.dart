import 'package:flutter/material.dart';
import 'package:media_kit_video/src/model/property_value_notifier.dart';

class ValueObserver<T> {
  final PropertyValueNotifier<T> _value;

  ValueObserver(T value) : _value = PropertyValueNotifier(value);

  void addListener(VoidCallback callback) {
    _value.addListener(callback);
  }

  void removeListener(VoidCallback callback) {
    _value.removeListener(callback);
  }

  void dispose() {
    _value.dispose();
  }

  set value(T newValue) {
    if (_value.value == newValue) {
      _value.notifyListeners();
    } else {
      _value.value = newValue;
    }
  }

  T get value => _value.value;

  ValueNotifier<T> get notifier => _value;
}
