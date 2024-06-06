import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';

///获取列表
class TencentCloudListData {
  static Future<List<String>?> getContentsList() async {
    try {
      BucketContents bucketContents = await Cos().getDefaultService().getBucket(
            TencentCloudAcquiesceData.postTextBucket,
            prefix: "", // 前缀匹配，用来规定返回的对象前缀地址
            maxKeys: 10, // 单次返回最大的条目数量，默认1000
          );

      List<Content?> contentsList = bucketContents.contentsList;

      List<String>? objectUrls = contentsList.map((object) {
        //对象的链接
        return "https://${TencentCloudAcquiesceData.postTextBucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/${object?.key}";
      }).toList();

      return objectUrls;
    } catch (e) {
      Logger().e("$e------------error");
    }
    return null;
  }
}
