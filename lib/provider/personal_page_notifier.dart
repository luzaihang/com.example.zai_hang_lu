import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/tencent/tencent_cloud_list_data.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

class PersonalPageNotifier with ChangeNotifier {
  TencentCloudListData tencentCloudListData = TencentCloudListData();
  final Cos cos = CosService().cos;

  int get selectedIndex => _selectedIndex;

  bool get isImageVisible => _isImageVisible;

  List<PostDetailFormJson> personalPostList = [];

  List<String> personalBannerImages = [];

  int _selectedIndex = 0;

  bool _isImageVisible = false;

  void showImage() {
    _isImageVisible = true;
    notifyListeners();
  }

  void hideImage() {
    _isImageVisible = false;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  ///获取数据
  Future<void> getPostData(String userId) async {
    personalPostList =
        await tencentCloudListData.getPersonalPostRefresh(userId) ?? [];
    personalPostList
        .sort((a, b) => b.postCreationTime.compareTo(a.postCreationTime));
    notifyListeners();
  }

  ///用户banner images
  Future<void> personalBanner(String userId) async {
    try {
      BucketContents bucketContents = await cos.getDefaultService().getBucket(
            DefaultConfig.avatarAndPostBucket,
            prefix: "$userId/bannerImgList",
            // 前缀匹配，用来规定返回的对象前缀地址
            maxKeys: 5, // 单次返回最大的条目数量，默认1000
          );

      List<Content?> contentsList = bucketContents.contentsList;

      List<String> objectUrls =
          contentsList.where((object) => object != null).map((object) {
        return "${DefaultConfig.avatarAndPostPrefix}/${object?.key}";
      }).toList();

      personalBannerImages = objectUrls;
      notifyListeners();
    } catch (e) {
      Logger().e("$e------------error");
    }
  }
}
