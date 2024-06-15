import 'package:flutter/material.dart';

class VisibilityNotifier extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void updateVisibility(bool isVisible) {
    if (_isVisible != isVisible) {
      _isVisible = isVisible;
      notifyListeners();
    }
  }
}
