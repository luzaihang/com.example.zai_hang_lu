import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

class OtherDataProvider with ChangeNotifier {
  int uploadCount = 0;

  ///上传到第几张
  void getUploadCount() {
    uploadCount++;
    Logger().d(uploadCount);
    notifyListeners();
  }

  int count = 0;

  ///单次上传图片的张数，用来决定弹窗的停留时间，单次最大50张(可更改)
  void getCount(int c) {
    count = c;
    Logger().d("------------------------$count");
    notifyListeners();
  }

  ///清理
  void clean() {
    uploadCount = 0;
    count = 0;
    notifyListeners();
  }
}
