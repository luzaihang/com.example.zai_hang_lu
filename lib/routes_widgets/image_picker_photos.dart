import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../provider/other_data_provider.dart';
import '../tencent/tencent_cloud_acquiesce_data.dart';
import '../tencent/tencent_upload_download.dart';

class ImagePickerPhotos {
  TencentUpLoadAndDownload tencentUpLoadAndDownload =
      TencentUpLoadAndDownload();

  ///选择图片
  Future<void> loadAssets(
      BuildContext context, OtherDataProvider otherDataProvider) async {
    List<Asset> resultList = <Asset>[];

    // 获取当前上下文的配置信息
    final ThemeData themeData = Theme.of(context);
    final Color primaryColor = themeData.colorScheme.primary;

    try {
      resultList = await MultiImagePicker.pickImages(
        // selectedAssets: images, //选择这个会在下次进入时，预选上次的图片
        cupertinoOptions: CupertinoOptions(
          doneButton: UIBarButtonItem(
            title: '确认',
            tintColor: primaryColor,
          ),
          cancelButton: UIBarButtonItem(
            title: '取消',
            tintColor: primaryColor,
          ),
          albumButtonColor: primaryColor,
          settings: const CupertinoSettings(
            theme: ThemeSetting(),
          ),
        ),
        materialOptions: const MaterialOptions(
          maxImages: 50,
          statusBarColor: Colors.blueGrey,
          //状态栏颜色
          enableCamera: false,
          actionBarColor: Colors.blueGrey,
          // 设置为主题颜色
          actionBarTitle: "已选择",
          allViewTitle: "全部",
          useDetailsView: false,
          selectCircleStrokeColor: Colors.white,
        ),
      );

      otherDataProvider.getCount(resultList.length);

      for (var asset in resultList) {
        String path = await getImageFilePath(asset);

        ///上传至腾讯云cos
        tencentUpLoadAndDownload.upLoad(path, otherDataProvider);
      }
    } on Exception catch (e) {
      Logger().e("图片选择出错--------------$e");
    }
  }

  ///图片转换为path
  Future<String> getImageFilePath(Asset asset) async {
    final byteData = await asset.getByteData();
    final buffer = byteData.buffer;

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final filePath = '$tempPath/${asset.name}';
    final file = File(filePath);
    await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file.path;
  }
}
