import 'package:flutter/material.dart';

class PostPageNotifier with ChangeNotifier {
  double index0 = 0.0;
  double index1 = 0.0;
  double index2 = 0.0;

  void setIndexOff(int dex, double offset) {
    switch (dex) {
      case 0:
        index0 = offset;
        break;
      case 1:
        index1 = offset;
        break;
      case 2:
        index2 = offset;
        break;
    }
    notifyListeners();
  }
}
