import 'package:flutter/material.dart';

class VisibilityNotifier extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  ///控制底部切换栏的显示、消失
  void updateVisibility(bool isVisible) {
    if (_isVisible != isVisible) {
      _isVisible = isVisible;
      notifyListeners();
    }
  }
}
