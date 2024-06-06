import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

class TencentCloudListBucket {
  void cloudListBucket() async {
    try {
      ListAllMyBuckets listAllMyBuckets =
          await Cos().getDefaultService().getService();
      // 存储桶列表详情请查看 ListAllMyBuckets 类

      Logger().d(listAllMyBuckets.buckets);
    } catch (e) {
      // 失败后会抛异常 根据异常进行业务处理
      Logger().e("获取bucket异常---------------$e");
    }
  }
}
