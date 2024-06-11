import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/chat_detail_factory.dart';
import 'package:ci_dong/tencent/tencent_cloud_acquiesce_data.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';

class ChattingRecordsList {
  static Future<List<ChatDetailSender>> recordsList() async {
    final Cos cos = CosService().cos;
    List<ChatDetailSender> decodedMaps = [];
    try {
      // 获取桶内容
      BucketContents bucketContents = await cos.getDefaultService().getBucket(
            TencentCloudAcquiesceData.chattingRecordsBucket,
            prefix: "${UserInfoConfig.uniqueID}/", // 前缀匹配，用来规定返回的对象前缀地址
            maxKeys: 200, //显示200个记录
          );

      List<Content?> contentsList = bucketContents.contentsList;

      // 生成对象URL列表
      List<String> objectUrls = contentsList
          .where((object) => object != null)
          .map((object) =>
              "https://${TencentCloudAcquiesceData.chattingRecordsBucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/${object?.key}")
          .toList();

      // 并发获取请求
      var responses =
          await Future.wait(objectUrls.map((url) => http.get(Uri.parse(url))));

      for (var response in responses) {
        if (response.statusCode == 200) {
          String decodedJsonString = utf8.decode(response.bodyBytes);
          if (decodedJsonString.trim().isNotEmpty) {
            List<dynamic> decodedMap = json.decode(decodedJsonString);
            for (var i in decodedMap) {
              if (i['senderID'] != UserInfoConfig.uniqueID) {
                ChatDetailSender userPost = ChatDetailSender.fromMap(i);
                decodedMaps.add(userPost);
                break; // 只添加第一个不匹配的记录
              }
            }
          }
        } else {
          Logger().e(
              "Failed to fetch data from ${response.request?.url}: ${response.statusCode}");
        }
      }

      return decodedMaps;
    } catch (e) {
      Logger().e("$e------------error");
      return [];
    }
  }
}
