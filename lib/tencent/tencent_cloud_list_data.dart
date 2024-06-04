import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';

///获取cloud列表 bucket -> userContent -> contentName -> xxx
class TencentCloudListData {
  Future<List<String>?> getContentsList() async {
    try {
      BucketContents bucketContents = await Cos().getDefaultService().getBucket(
          TencentCloudAcquiesceData.bucket!,
          /// 前缀匹配，用来规定返回的对象前缀地址
          prefix:
              "${TencentCloudAcquiesceData.contentPrefix}${TencentCloudAcquiesceData.contentName}/",
          maxKeys: 100 // 单次返回最大的条目数量，默认1000
          );

      List<Content?> contentsList = bucketContents.contentsList;

      List<String>? objectUrls = contentsList
          .where(

              ///排除.txt文件
              (object) => object?.key != null && !object!.key.endsWith('.txt'))
          .map((object) {
        //对象的链接
        return "https://${TencentCloudAcquiesceData.bucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/${object?.key}";
      }).toList();
      Logger().d("-----------------$objectUrls");

      return objectUrls;
    } catch (e) {
      Logger().e("$e------------error");
    }
    return null;
  }
}
