import 'package:ci_dong/tencent/tencent_cloud_download.dart';
import 'package:flutter/cupertino.dart';

class PersonalNameNotifier with ChangeNotifier {
  final Map<String, String> _userNames = {};

  // 获取并缓存用户名称的方法
  Future<void> fetchAndCacheUserName(String userId) async {
    if (!_userNames.containsKey(userId)) {
      // 模拟获取用户名的过程，假设这里有异步查询操作
      String fetchedName = await TencentCloudTxtDownload.personalName(userId);
      _userNames[userId] = fetchedName;
      notifyListeners();
    }
  }

  String getCachedName(String userId) {
    return _userNames[userId] ?? '次动';
  }
}
