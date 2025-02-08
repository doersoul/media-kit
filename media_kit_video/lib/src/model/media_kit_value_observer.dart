import 'package:flutter/material.dart';
import 'package:media_kit_video/src/model/media_kit_property_value_notifier.dart';

class MediaKitValueObserver<T> {
  final MediaKitPropertyValueNotifier<T> _value;

  MediaKitValueObserver(T value)
      : _value = MediaKitPropertyValueNotifier(value);

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
