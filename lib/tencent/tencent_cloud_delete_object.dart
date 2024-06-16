import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';
import 'package:logger/logger.dart';

class TencentCloudDeleteObject {
  final cos = CosService().cos;

  Future<void> cloudDeleteObject(String cosPath) async {
    try {
      await cos.getDefaultService().deleteObject(
            DefaultConfig.avatarAndPostBucket,
            "${UserInfoConfig.uniqueID}/bannerImgList/$cosPath",
            region: DefaultConfig.region,
          );

      Logger().i("--------------message");
    } catch (e) {
      // 失败后会抛异常 根据异常进行业务处理
      Logger().e("删除有误---------$e");
    }
  }
}
