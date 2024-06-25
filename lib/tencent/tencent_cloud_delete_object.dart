import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/main.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';

class TencentCloudDeleteObject {
  final cos = CosService().cos;

  Future<void> cloudDeleteObject(String cosPath) async {
    try {
      await cos.getDefaultService().deleteObject(
            DefaultConfig.personalInfoBucket,
            "${UserInfoConfig.uniqueID}/bannerImgList/$cosPath",
            region: DefaultConfig.region,
          );

    } catch (e) {
      // 失败后会抛异常 根据异常进行业务处理
      appLogger.e("删除有误---------$e");
    }
  }
}
