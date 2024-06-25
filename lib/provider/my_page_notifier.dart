import 'dart:io';
import 'package:ci_dong/app_data/compress_image.dart';
import 'package:ci_dong/app_data/show_custom_snackBar.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/main.dart';
import 'package:ci_dong/tencent/tencent_cloud_delete_object.dart';
import 'package:ci_dong/tencent/tencent_cloud_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import '../tencent/tencent_cloud_list_data.dart';

class MyPageNotifier with ChangeNotifier {
  TencentCloudDeleteObject tencentCloudDeleteObject =
      TencentCloudDeleteObject();
  CompressImage compressImage = CompressImage();

  ///选择banner图片，准备上传
  final List<String> _imageFilesPath = [];
  List<Asset> _imageAssets = <Asset>[];

  ///banner图片list
  List<String> bannerImgList = [];

  ///选择用户头像，准备上传
  final List<String> _userAvatarPath = [];
  List<Asset> _userAvatarAsset = <Asset>[];

  String newAvatarUrl = "";

  Future<void> myPageImageFile(BuildContext context, bool userAvatar) async {
    List<Asset> resultList = <Asset>[];
    _imageFilesPath.clear();
    _userAvatarPath.clear();

    try {
      resultList = await MultiImagePicker.pickImages(
        // selectedAssets: userAvatar ? [] : _imageAssets,
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
          selectionLimitReachedText: userAvatar ? "只能选择一张作为头像" : "最多选择5张",
        ),
      );
    } catch (e) {
      appLogger.e(e);
    }

    if (!context.mounted) return;

    if (!userAvatar) {
      _imageAssets = resultList;
      if (_imageAssets.isNotEmpty) {
        for (var item in bannerImgList) {
          String fileName = item.split('/').last;
          //只能单个删除
          await tencentCloudDeleteObject.cloudDeleteObject(fileName);
        }
        if (context.mounted) showCustomSnackBar(context, "正在更新图片中...");
      }

      for (var asset in _imageAssets) {
        File file = await compressImage.getImageFileFromAsset(asset);
        XFile compressedImage = await compressImage.compressImage(file);

        await bannerImageUpLoad(compressedImage.path);
      }
      bannerImgList = await bannerImgFun();
    } else {
      _userAvatarAsset = resultList;

      File file =
          await compressImage.getImageFileFromAsset(_userAvatarAsset.first);
      XFile compressedImage = await compressImage.compressImage(file);

      if (context.mounted) showCustomSnackBar(context, "正在更新头像中...");
      String res =
          await userAvatarUpLoad(compressedImage.path, UserInfoConfig.uniqueID);
      if (res.isNotEmpty) {
        newAvatarUrl = res;
      } else {
        if (context.mounted) showCustomSnackBar(context, "头像更新失败,稍候再试");
      }
    }

    notifyListeners();
  }

  void getBanner() async {
    bannerImgList = await bannerImgFun();
    notifyListeners();
  }
}
