import 'dart:convert';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/chat_detail_from_map.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';

class ChattingRecordsList {
  static Future<List<ChatDetailFromMap>> recordsList() async {
    final Cos cos = CosService().cos;
    List<ChatDetailFromMap> decodedMaps = [];
    try {
      // 获取桶内容
      BucketContents bucketContents = await cos.getDefaultService().getBucket(
            DefaultConfig.chattingRecordsBucket,
            prefix: "${UserInfoConfig.uniqueID}/", // 前缀匹配，用来规定返回的对象前缀地址
            maxKeys: 200, //显示200个记录,联系的用户
          );

      List<Content?> contentsList = bucketContents.contentsList;

      // 生成对象URL列表
      List<String> objectUrls = contentsList
          .where((object) => object != null)
          .map((object) =>
              "${DefaultConfig.chattingRecordsPrefix}/${object?.key}")
          .toList();

      // 并发获取请求
      var responses =
          await Future.wait(objectUrls.map((url) => http.get(Uri.parse(url))));

      for (var response in responses) {
        if (response.statusCode == 200) {
          String decodedJsonString = utf8.decode(response.bodyBytes);
          if (decodedJsonString.trim().isNotEmpty) {
            List<dynamic> decodedMap = json.decode(decodedJsonString);
            Logger().d(decodedMap);

            Map<String, dynamic> data = {
              "senderName": "",
              "senderID": "",
              "senderAvatar": "",
              "message": "",
              "time": "",
            };

            //消息内容、时间都是取最后一个
            var lastMap = decodedMap.last;
            data['message'] = lastMap['message'];
            data['time'] = lastMap['time'];

            for (var item in decodedMap) {
              if (item['senderID'] != UserInfoConfig.uniqueID) {
                //头像、名称、id都是取对方的
                data["senderName"] = item['senderName'];
                data['senderID'] = item['senderID'];
                data['senderAvatar'] = item['senderAvatar'];
                ChatDetailFromMap chatDetail = ChatDetailFromMap.fromMap(data);
                decodedMaps.add(chatDetail);
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
