import 'package:flutter/material.dart';

///全局性provider
class AppShareDataProvider with ChangeNotifier {

  List<String>? objectUrls;

  void getUrls(List<String>? urls) {
    objectUrls = urls;
    notifyListeners();
  }
}
