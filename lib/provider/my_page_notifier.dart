import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/tencent/tencent_cloud_delete_object.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

class MyPageNotifier with ChangeNotifier {
  final Cos cos = CosService().cos;
  TencentCloudDeleteObject tencentCloudDeleteObject =
      TencentCloudDeleteObject();

  ///选择banner图片，准备上传
  final List<String> _imageFilesPath = [];
  List<Asset> _imageAssets = <Asset>[];

  ///banner图片list
  List<String> bannerImgList = [];

  ///选择用户头像，准备上传
  final List<String> _userAvatarPath = [];
  List<Asset> _userAvatarAsset = <Asset>[];

  Future<void> myPageImageFile(BuildContext context, bool userAvatar) async {
    List<Asset> resultList = <Asset>[];
    _imageFilesPath.clear();
    _userAvatarPath.clear();

    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: userAvatar ? [] : _imageAssets,
        materialOptions: MaterialOptions(
          maxImages: userAvatar ? 1 : 5,
          // startInAllView: true, //这个目前使用之后，没有返回数据
          statusBarColor: const Color(0xFF052D84),
          actionBarColor: const Color(0xFF052D84),
          actionBarTitle: "选择",
          allViewTitle: "全部",
          useDetailsView: false,
          backButtonDrawable: "@drawable/back_icon",
          selectCircleStrokeColor: Colors.white,
          selectionLimitReachedText: userAvatar ? "只能选择一张作为头像" : "最多选择9张",
        ),
      );
    } catch (e) {
      Logger().e(e);
    }

    if (!context.mounted) return;

    if (!userAvatar) {
      _imageAssets = resultList;
      if (_imageAssets.isNotEmpty) {
        Loading().show(context);
        for (var item in bannerImgList) {
          String fileName = item.split('/').last;
          //只能单个删除
          await tencentCloudDeleteObject.cloudDeleteObject(fileName);
        }
      }

      for (var asset in _imageAssets) {
        String path = await getImageFileFromAsset(asset);
        _imageFilesPath.add(path);

        await bannerImageUpLoad(path);
      }
      Loading().hide();
      bannerImgFun();
    } else {
      _userAvatarAsset = resultList;

      String fileName = await getImageFileFromAsset(_userAvatarAsset.first);
      await userAvatarUpLoad(fileName);
    }

    notifyListeners();
  }

  Future<String> getImageFileFromAsset(Asset asset) async {
    final byteData = await asset.getByteData();
    final tempFile =
        File('${(await getTemporaryDirectory()).path}/${asset.name}');
    final file = await tempFile.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }

  ///用户banner图片上传
  Future<bool> bannerImageUpLoad(String imagePath) async {
    TencentUpLoadAndDownload tencentUpLoadAndDownload =
        TencentUpLoadAndDownload();
    String filename = imagePath.split('/').last;
    String cosPath = "${UserInfoConfig.uniqueID}/bannerImgList/$filename";
    return tencentUpLoadAndDownload.uploadFile(
      DefaultConfig.avatarAndPostBucket,
      cosPath,
      filePath: imagePath,
    );
  }

  ///用户banner图片获取
  Future<void> bannerImgFun() async {
    try {
      BucketContents bucketContents = await cos.getDefaultService().getBucket(
            DefaultConfig.avatarAndPostBucket,
            prefix: "${UserInfoConfig.uniqueID}/bannerImgList",
            // 前缀匹配，用来规定返回的对象前缀地址
            maxKeys: 10, // 单次返回最大的条目数量，默认1000
          );

      List<Content?> contentsList = bucketContents.contentsList;

      List<String> objectUrls =
          contentsList.where((object) => object != null).map((object) {
        return "${DefaultConfig.avatarAndPostPrefix}/${object?.key}";
      }).toList();

      bannerImgList = objectUrls;
      notifyListeners();
    } catch (e) {
      Logger().e("$e------------error");
      // return null;
    }
  }

  ///用户头像上传
  Future<bool> userAvatarUpLoad(String imagePath) async {
    TencentUpLoadAndDownload tencentUpLoadAndDownload =
        TencentUpLoadAndDownload();
    String cosPath = "${UserInfoConfig.uniqueID}/userAvatar.png";
    bool result = await tencentUpLoadAndDownload.uploadFile(
      DefaultConfig.avatarAndPostBucket,
      cosPath,
      filePath: imagePath,
    );

    String string = "${DefaultConfig.avatarAndPostPrefix}/$cosPath";
    if (result) CachedNetworkImage.evictFromCache(string);
    return result;
  }
}
