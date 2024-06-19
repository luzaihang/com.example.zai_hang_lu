import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // 禁止返回键关闭加载框
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF052D84).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(
                    color: Colors.white,
                    size: 20.0,
                  ),
                ],
              ),
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
