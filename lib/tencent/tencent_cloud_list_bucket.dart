import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';

class TencentCloudListBucket {
  final Cos cos = CosService().cos;

  void cloudListBucket() async {
    try {
      ListAllMyBuckets listAllMyBuckets =
          await cos.getDefaultService().getService();
      // 存储桶列表详情请查看 ListAllMyBuckets 类

    } catch (e) {
      // 失败后会抛异常 根据异常进行业务处理
    }
  }
}
