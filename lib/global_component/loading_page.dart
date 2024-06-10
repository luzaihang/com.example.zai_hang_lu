import 'package:flutter/material.dart';

class Loading {
  static final Loading _instance = Loading._internal();

  factory Loading() {
    return _instance;
  }

  Loading._internal();

  // 记录当前的context
  BuildContext? _context;
  bool _isLoading = false;

  ///开启loading
  void show(BuildContext context) {
    if (_isLoading) return; // 防止重复显示
    _isLoading = true;
    _context = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // 禁止返回键关闭加载框
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white.withOpacity(0.7),
              backgroundColor: Colors.blueGrey,
              strokeWidth: 2.5,
              strokeCap: StrokeCap.round,
            ),
          ),
        );
      },
    );
  }

  ///关闭loading
  void hide() {
    if (!_isLoading) return;
    _isLoading = false;
    if (_context != null) {
      Navigator.of(_context!).pop();
      _context = null;
    }
  }
}
