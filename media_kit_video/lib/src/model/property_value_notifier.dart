import 'package:flutter/material.dart';

class PropertyValueNotifier<T> extends ValueNotifier<T> {
  PropertyValueNotifier(super.value);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
