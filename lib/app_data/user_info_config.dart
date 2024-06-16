import 'dart:io';

import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/tencent/tencent_cloud_acquiesce_data.dart';

class UserInfoConfig {
  ///用户名，也是注册时的名称
  static String userName = "";

  ///用户密码
  static String userPassword = "";

  ///用户头像
  static String userAvatar = "";

  ///用户唯一ID
  static String uniqueID = "";
}

///固定链接，唯有id不同
Future<String> allAvatarUrl() async {
  try {
    String url =
        "https://${DefaultConfig.avatarAndPostBucket}.cos.${DefaultConfig.region}.myqcloud.com/${UserInfoConfig.uniqueID}/userAvatar.png";
    bool res = await checkUrlExists(url);
    if (!res) {
      return "";
    }

    return url;
  } catch (e) {
    return "";
  }
}

///验证链接是否存在
Future<bool> checkUrlExists(String urlString) async {
  final url = Uri.parse(urlString);
  final httpClient = HttpClient()
    ..connectionTimeout = const Duration(milliseconds: 1000); // 设置连接超时时间

  try {
    final request = await httpClient.headUrl(url);
    request.followRedirects = false;
    final response = await request.close();
    return response.statusCode == HttpStatus.ok;
  } catch (e) {
    return false;
  } finally {
    httpClient.close();
  }
}
