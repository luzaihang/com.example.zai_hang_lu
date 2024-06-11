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
String allAvatarUrl(String id) {
  return "https://${TencentCloudAcquiesceData.avatarAndPost}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/$id/userAvatar.png";
}
