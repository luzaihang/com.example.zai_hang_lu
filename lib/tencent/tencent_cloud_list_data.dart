import 'dart:convert';

import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:http/http.dart' as http;
import 'package:ci_dong/tencent/tencent_cloud_service.dart';

///获取列表
class TencentCloudListData {
  bool allIsTruncated = false;
  String? allNextMarker;

  bool userIsTruncated = false;
  String? userNextMarker;

  final Cos cos = CosService().cos;

  Future<List<PostDetailFormJson>?> _fetchContentsList(bool allTab,
      {String? marker}) async {
    List<PostDetailFormJson> decodedMaps = [];
    try {
      BucketContents bucketContents = await cos.getDefaultService().getBucket(
            allTab
                ? DefaultConfig.postTextBucket
                : DefaultConfig.avatarAndPostBucket,
            // 前缀匹配，用来规定返回的对象前缀地址
            prefix: allTab ? "" : "${UserInfoConfig.uniqueID}/post",
            marker: marker,
            maxKeys: allTab ? 20 : 1000, // 单次返回最大的条目数量，默认1000
          );

      if (allTab) {
        allIsTruncated = bucketContents.isTruncated;
        allNextMarker = bucketContents.nextMarker;
      } else {
        userIsTruncated = bucketContents.isTruncated;
        userNextMarker = bucketContents.nextMarker;
      }

      List<Content?> contentsList = bucketContents.contentsList;

      List<String> objectUrls =
          contentsList.where((object) => object != null).map((object) {
        if (allTab) {
          return "${DefaultConfig.postTextPrefix}/${object?.key}";
        } else {
          return "${DefaultConfig.avatarAndPostPrefix}/${object?.key}";
        }
      }).toList();

      var responses =
          await Future.wait(objectUrls.map((url) => http.get(Uri.parse(url))));

      for (var response in responses) {
        if (response.statusCode == 200) {
          String decodedJsonString = utf8.decode(response.bodyBytes);
          if (decodedJsonString.trim().isNotEmpty) {
            Map<String, dynamic> decodedMap = json.decode(decodedJsonString);
            PostDetailFormJson postJson = PostDetailFormJson.fromJson(decodedMap);
            decodedMaps.add(postJson);
          }
        } else {
          Logger().e(
              "Failed to fetch data from ${response.request?.url}: ${response.statusCode}");
        }
      }

      return decodedMaps;
    } catch (e) {
      Logger().e("$e------------error");
      return null;
    }
  }

  Future<List<PostDetailFormJson>?> getAllFirstContentsList() async {
    return _fetchContentsList(true);
  }

  Future<List<PostDetailFormJson>?> getAllNextContentsList() async {
    if (allIsTruncated) {
      return _fetchContentsList(true, marker: allNextMarker);
    } else {
      return [];
    }
  }

  Future<List<PostDetailFormJson>?> getUserPostFirstContentsList() async {
    return _fetchContentsList(false);
  }

  Future<List<PostDetailFormJson>?> getUserPostNextContentsList() async {
    if (allIsTruncated) {
      return _fetchContentsList(false, marker: allNextMarker);
    } else {
      return [];
    }
  }
}
