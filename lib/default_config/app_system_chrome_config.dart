import 'package:flutter/services.dart';

///状态栏更改
void systemChromeColor(Color color, Brightness status) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: color, // 状态栏背景色
      statusBarIconBrightness: status, // 状态栏图标亮度
    ),
  );
}