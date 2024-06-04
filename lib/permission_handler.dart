import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class PermissionHandler {
  static const _platform = MethodChannel('com.example.zai_hang_lu');

  static Future<bool> requestStoragePermission() async {
    try {
      final bool isGranted = await _platform.invokeMethod('requestStoragePermission');

      _platform.setMethodCallHandler((call) async {
        if (call.method == 'permissionResult') {
          final bool result = call.arguments as bool;
          return result;
        }
      });

      return isGranted;

      ///可以使用它
      // Future<String> requestStoragePermission() async {
      //   bool isGranted = await PermissionHandler.requestStoragePermission();
      //     return isGranted ? 'Granted' : 'Denied';
      // }
    } on PlatformException {
      return false;
    }
  }
}