import 'dart:io';

import 'package:ci_dong/app_data/compress_image.dart';
import 'package:ci_dong/app_data/post_content_config.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/factory_list/personal_folder_from_map.dart';
import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/tencent/tencent_cloud_download.dart';
import 'package:ci_dong/tencent/tencent_cloud_list_data.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';
import 'package:ci_dong/tencent/tencent_cloud_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

class PersonalPageNotifier with ChangeNotifier {
  TencentCloudListData tencentCloudListData = TencentCloudListData();
  final Cos cos = CosService().cos;
  CompressImage compressImage = CompressImage();
  PostContentConfig postContentConfig = PostContentConfig();

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
            DefaultConfig.personalInfoBucket,
            prefix: "$userId/bannerImgList",
            // 前缀匹配，用来规定返回的对象前缀地址
            maxKeys: 5, // 单次返回最大的条目数量，默认1000
          );

      List<Content?> contentsList = bucketContents.contentsList;

      List<String> objectUrls =
          contentsList.where((object) => object != null).map((object) {
        return "${DefaultConfig.personalInfoPrefix}/${object?.key}";
      }).toList();

      personalBannerImages = objectUrls;
      notifyListeners();
    } catch (e) {
    }
  }

  List<PersonalFolderFromMap> folderList = [];

  ///获取个人全部文件夹数据
  Future<void> personalFolder(String userId) async {
    folderList = await TencentCloudTxtDownload.personalFolderImages(userId);
    notifyListeners();
  }

  ///选择banner图片，准备上传
  final List<String> _imageFilesPath = [];
  List<Asset> _imageAssets = <Asset>[];

  ///选择图片，并且上传
  Future<void> personalPageImageFile(
      BuildContext context, PersonalFolderFromMap folderFromMap) async {
    List<Asset> resultList = <Asset>[];
    _imageFilesPath.clear();
    postContentConfig.cleanFolderImages();

    try {
      resultList = await MultiImagePicker.pickImages(
        materialOptions: const MaterialOptions(
          maxImages: 50,
          statusBarColor: Color(0xFF052D84),
          actionBarColor: Color(0xFF052D84),
          actionBarTitle: "选择",
          allViewTitle: "全部",
          useDetailsView: false,
          backButtonDrawable: "@drawable/back_icon",
          selectCircleStrokeColor: Colors.white,
          selectionLimitReachedText: "最多选择50张",
        ),
      );
    } catch (e) {
      //().e(e);
    }

    _imageAssets = resultList;
    //().d(_imageAssets.length);

    if (_imageAssets.isEmpty) {
      return;
    }

    for (var i in _imageAssets) {
      File file = await compressImage.getImageFileFromAsset(i);

      XFile compressedImage = await compressImage.compressImage(file);
      _imageFilesPath.add(compressedImage.path);
    }

    if (_imageFilesPath.isNotEmpty) {
      List<Future<bool>> uploadFutures = _imageFilesPath.map((imagePath) {
        return personalFolderImageUpLoad(imagePath, folderFromMap.folderId,
            UserInfoConfig.uniqueID, postContentConfig);
      }).toList();

      List<bool> results = await Future.wait(uploadFutures);

      if (results.every((result) => result)) {
        PersonalFolderFromMap getMap = folderFromMap.copyWith(
            images: postContentConfig.personalFolderUploadImagePaths);
        folderList.add(getMap);

        List<Map> listOfMaps =
            folderList.map((folder) => folder.toMap()).toList();

        personalFolderTxtUpLoad(
            listOfMaps, getMap.folderId, UserInfoConfig.uniqueID);
        //().d(getMap.toMap());
      }
    }

    notifyListeners();
  }
}
