import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class ImageSaver {
  // 静态方法，可以从任何地方调用
  static Future<void> saveImage(BuildContext context, String url,
      {String imageName = 'image'}) async {
    var status = await Permission.storage.request();

    if (Platform.isIOS) {
      // 请求 iOS 特定的保存图片权限
      var status = await Permission.photosAddOnly.request();

      if (status.isGranted) {
      } else if (status.isDenied) {
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        // 获取图片数据
        final response = await http.get(Uri.parse(url));
        final Uint8List bytes = response.bodyBytes;

        // 保存图片到本地相册
        final result = await ImageGallerySaver.saveImage(bytes, name: imageName);
        return;
      }

      if (Platform.isAndroid && await isAtLeastAndroid13()) {
        // Android 13 及以上单独请求媒体权限
        var imageStatus = await Permission.photos.request();
        var videoStatus = await Permission.videos.request();

        if (imageStatus.isGranted && videoStatus.isGranted) {
          // 获取图片数据
          final response = await http.get(Uri.parse(url));
          final Uint8List bytes = response.bodyBytes;

          // 保存图片到本地相册
          final result = await ImageGallerySaver.saveImage(bytes, name: imageName);
        } else {
          if (await Permission.photos.isPermanentlyDenied ||
              await Permission.videos.isPermanentlyDenied) {
            await openAppSettings();
          }
        }
      } else {
        // Android 13 以下版本请求存储权限
        var storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
        } else {
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
  //().d(version);
  return version >= 33;  // Android 13 是 API level 33
}

Future<int> getSystemVersion() async {
  var version = await const MethodChannel('com.example.ci_dong').invokeMethod('getSystemVersion');
  return version ?? 0;
}