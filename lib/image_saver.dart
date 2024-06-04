import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:zai_hang_lu/permission_handler.dart';

class ImageSaver {
  // 静态方法，可以从任何地方调用
  static Future<void> saveImage(BuildContext context, String url,
      {String imageName = 'image'}) async {
    var status = await Permission.storage.request();

    if (Platform.isIOS) {
      // 请求 iOS 特定的保存图片权限
      var status = await Permission.photosAddOnly.request();

      if (status.isGranted) {
        Logger().d('iOS Photos add permission granted');
      } else if (status.isDenied) {
        Logger().d('iOS Photos add permission denied');
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        Logger().i("开始-----------操作：保存图片");
        // 获取图片数据
        final response = await http.get(Uri.parse(url));
        final Uint8List bytes = response.bodyBytes;

        // 保存图片到本地相册
        final result = await ImageGallerySaver.saveImage(bytes, name: imageName);
        return;
      }

      if (Platform.isAndroid && await isAtLeastAndroid13()) {
        Logger().d(isAtLeastAndroid13());
        // Android 13 及以上单独请求媒体权限
        var imageStatus = await Permission.photos.request();
        var videoStatus = await Permission.videos.request();

        if (imageStatus.isGranted && videoStatus.isGranted) {
          Logger().i("开始-----------操作：保存图片");
          // 获取图片数据
          final response = await http.get(Uri.parse(url));
          final Uint8List bytes = response.bodyBytes;

          // 保存图片到本地相册
          final result = await ImageGallerySaver.saveImage(bytes, name: imageName);
          Logger().d(result);
        } else {
          Logger().d('媒体权限未获取');
          if (await Permission.photos.isPermanentlyDenied ||
              await Permission.videos.isPermanentlyDenied) {
            await openAppSettings();
          }
        }
      } else {
        // Android 13 以下版本请求存储权限
        var storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          Logger().d('存储权限已获取');
        } else {
          Logger().d('存储权限未获取');
          if (await Permission.storage.isPermanentlyDenied) {
            await openAppSettings();
          }
        }
      }
    }
  }
}

Future<bool> isAtLeastAndroid13() async {
  var version = await getSystemVersion();
  Logger().d(version);
  return version >= 33;  // Android 13 是 API level 33
}

Future<int> getSystemVersion() async {
  var version = await const MethodChannel('com.example.zai_hang_lu').invokeMethod('getSystemVersion');
  return version ?? 0;
}