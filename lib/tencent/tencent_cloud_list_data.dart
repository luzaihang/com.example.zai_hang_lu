import 'dart:convert';

import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/main.dart';
import 'package:ci_dong/my_page/banner_images_cache_data.dart';
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

  /// userId为null或者''时，就说明要获取所有人的帖子列表
  Future<List<PostDetailFormJson>?> _fetchContentsList(String? userId,
      {String? marker}) async {
    List<PostDetailFormJson> decodedMaps = [];
    try {
      BucketContents bucketContents = await cos.getDefaultService().getBucket(
            userId == null || userId.isEmpty
                ? DefaultConfig.postTextBucket
                : DefaultConfig.personalInfoBucket,
            // 前缀匹配，用来规定返回的对象前缀地址
            prefix: userId == null || userId.isEmpty ? "" : "$userId/post",
            marker: marker,
            maxKeys: userId == null || userId.isEmpty
                ? 20
                : 1000, // 单次返回最大的条目数量，默认1000
          );

      if (userId == null || userId.isEmpty) {
        allIsTruncated = bucketContents.isTruncated;
        allNextMarker = bucketContents.nextMarker;
      } else {
        userIsTruncated = bucketContents.isTruncated;
        userNextMarker = bucketContents.nextMarker;
      }

      List<Content?> contentsList = bucketContents.contentsList;

      List<String> objectUrls =
          contentsList.where((object) => object != null).map((object) {
        if (userId == null || userId.isEmpty) {
          return "${DefaultConfig.postTextPrefix}/${object?.key}";
        } else {
          return "${DefaultConfig.personalInfoPrefix}/${object?.key}";
        }
      }).toList();

      var responses =
          await Future.wait(objectUrls.map((url) => http.get(Uri.parse(url))));

      for (var response in responses) {
        if (response.statusCode == 200) {
          String decodedJsonString = utf8.decode(response.bodyBytes);
          if (decodedJsonString.trim().isNotEmpty) {
            Map<String, dynamic> decodedMap = json.decode(decodedJsonString);
            PostDetailFormJson postJson =
                PostDetailFormJson.fromJson(decodedMap);
            decodedMaps.add(postJson);
          }
        } else {
        }
      }

      return decodedMaps;
    } catch (e) {
      appLogger.e(e);
      return null;
    }
  }

  ///全部列表的刷新
  Future<List<PostDetailFormJson>?> getAllPostRefresh() async {
    return _fetchContentsList(null);
  }

  ///全部列表的上拉加载
  Future<List<PostDetailFormJson>?> getAllPostGain() async {
    if (allIsTruncated) {
      return _fetchContentsList(null, marker: allNextMarker);
    } else {
      return [];
    }
  }

  ///刷新数据，获得最新数据
  Future<List<PostDetailFormJson>?> getPersonalPostRefresh(
      String userId) async {
    return _fetchContentsList(userId);
  }

  ///上拉加载数据
  Future<List<PostDetailFormJson>?> getPersonalPostGain(String userId) async {
    if (userNextMarker != null) {
      return _fetchContentsList(userId, marker: userNextMarker);
    } else {
      return [];
    }
  }
}

///用户banner图片获取
Future<List<String>> bannerImgFun() async {
  final Cos cos = CosService().cos;
  List<String> list = await BannerImageCache().loadBannerImgList();
  if (list.isNotEmpty) {
    return list;
  }
  try {
    BucketContents bucketContents = await cos.getDefaultService().getBucket(
          DefaultConfig.personalInfoBucket,
          prefix: "${UserInfoConfig.uniqueID}/bannerImgList",
// 前缀匹配，用来规定返回的对象前缀地址
          maxKeys: 5, // 单次返回最大的条目数量，默认1000
        );

    List<Content?> contentsList = bucketContents.contentsList;

    List<String> objectUrls =
        contentsList.where((object) => object != null).map((object) {
      return "${DefaultConfig.personalInfoPrefix}/${object?.key}";
    }).toList();

    BannerImageCache().saveBannerImgList(objectUrls);
    return objectUrls;
  } catch (e) {
    appLogger.e(e);
    return [];
  }
}
