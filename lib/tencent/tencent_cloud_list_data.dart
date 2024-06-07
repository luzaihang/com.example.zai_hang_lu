import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:zai_hang_lu/factory_list/home_list_data.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';
import 'package:http/http.dart' as http;

///获取列表
class TencentCloudListData {
  bool isTruncated = false;
  String? nextMarker;

  Future<List<UserPost>?> _fetchContentsList({String? marker}) async {
    List<UserPost> decodedMaps = [];
    try {
      BucketContents bucketContents = await Cos().getDefaultService().getBucket(
            TencentCloudAcquiesceData.postTextBucket,
            prefix: "", // 前缀匹配，用来规定返回的对象前缀地址
            marker: marker,
            maxKeys: 10, // 单次返回最大的条目数量，默认1000
          );

      isTruncated = bucketContents.isTruncated;
      nextMarker = bucketContents.nextMarker;

      List<Content?> contentsList = bucketContents.contentsList;

      List<String> objectUrls =
          contentsList.where((object) => object != null).map((object) {
        return "https://${TencentCloudAcquiesceData.postTextBucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/${object?.key}";
      }).toList();

      var responses =
          await Future.wait(objectUrls.map((url) => http.get(Uri.parse(url))));

      for (var response in responses) {
        if (response.statusCode == 200) {
          String decodedJsonString = utf8.decode(response.bodyBytes);
          if (decodedJsonString.trim().isNotEmpty) {
            Map<String, dynamic> decodedMap = json.decode(decodedJsonString);
            UserPost userPost = UserPost.fromJson(decodedMap);
            decodedMaps.add(userPost);
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

  Future<List<UserPost>?> getFirstContentsList() async {
    return _fetchContentsList();
  }

  Future<List<UserPost>?> getNextContentsList() async {
    if (isTruncated) {
      return _fetchContentsList(marker: nextMarker);
    } else {
      return [];
    }
  }
}
