import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

Widget headerRefresh() {
  return const WaterDropHeader(
    idleIcon: Icon(
      Icons.circle,
      color: Colors.white,
      size: 10,
    ),
    waterDropColor: Color(0xFF052D84),
    complete: Text(
      "刷新完成",
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF052D84),
      ),
    ),
    failed: Text(
      "刷新失败",
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF052D84),
      ),
    ),
    refresh: SpinKitFoldingCube(
      color: Color(0xFF052D84),
      size: 20.0,
      duration: Duration(milliseconds: 800),
    ),
  );
}

Widget footerLoad() {
  return const ClassicFooter(
    textStyle: TextStyle(
      fontSize: 12,
      color: Color(0xFF052D84),
    ),
    loadingText: "",
    loadingIcon: SpinKitThreeBounce(
      color: Color(0xFF052D84),
      size: 13.0,
      duration: Duration(milliseconds: 800),
    ),
    failedText: "加载失败",
    failedIcon: null,
    noDataText: "",
    noMoreIcon: null,
    idleText: "- 已经到底了 -",
    canLoadingIcon: null,
    canLoadingText: "",
    idleIcon: null,
  );
}
