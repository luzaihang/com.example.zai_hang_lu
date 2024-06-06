import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:zai_hang_lu/factory_list/home_list_data.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';
import 'package:http/http.dart' as http;

///获取列表
class TencentCloudListData {
  static Future<List<UserPost>?> getContentsList() async {
    List<UserPost> decodedMaps = [];
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

      for (String element in objectUrls) {
        try {
          final response = await http.get(Uri.parse(element));

          if (response.statusCode == 200) {
            // 获取ResponseBody的字节列表
            List<int> bytes = response.bodyBytes;

            // 第一步：将 Uint8List 转换为 JSON 字符串
            String decodedJsonString = utf8.decode(bytes);
            if (decodedJsonString.trim().isNotEmpty) {
              // 第二步：将 JSON 字符串解码为 Map
              Map<String, dynamic> decodedMap = json.decode(decodedJsonString);
              UserPost userPost = UserPost.fromJson(decodedMap);
              decodedMaps.add(userPost);
            }
          } else {}
        } catch (e) {
          Logger().e("$e-----------txt异常");
        }
      }

      Logger().d(decodedMaps);

      return decodedMaps;
    } catch (e) {
      Logger().e("$e------------error");
    }
    return null;
  }
}
