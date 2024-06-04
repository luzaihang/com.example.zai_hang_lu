import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';

class TencentCloudDeleteObject {
  void cloudDeleteObject() async {
// 存储桶名称，由 bucketname-appid 组成，appid 必须填入，可以在 COS 控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
    String bucket = "examplebucket-1250000000";
//对象在存储桶中的位置标识符，即对象键
    String cosPath = "exampleobject";
// 存储桶所在地域简称，例如广州地区是 ap-guangzhou
    String region = "COS_REGION";
    //examplebucket-1250000000.cos.ap-guangzhou.myqcloud.com/doc/picture.jpg
    try {
      await Cos()
          .getDefaultService()
          .deleteObject(bucket, cosPath, region: region);
    } catch (e) {
      // 失败后会抛异常 根据异常进行业务处理
      Logger().e("删除有误---------$e");
    }
  }
}
