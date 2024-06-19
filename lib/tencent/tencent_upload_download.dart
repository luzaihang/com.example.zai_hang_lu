import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ci_dong/app_data/app_encryption_helper.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';
import 'package:ci_dong/app_data/post_content_data.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';

class TencentUpLoadAndDownload {
  final Cos cos;
  CosTransferManger transferManager;

  // 构造函数
  TencentUpLoadAndDownload()
      : cos = CosService().cos,
        transferManager = CosService().cos.getDefaultTransferManger();

  Future<bool> uploadFile(String bucket, String cosPath,
      {String? filePath,
      Uint8List? byteArr,
      PostContentData? postContentData}) async {
    Completer<bool> completer = Completer<bool>();

    void successCallBack(result) {
      Logger().i("文件上传成功");
      if (filePath != null && filePath.isNotEmpty && postContentData != null) {
        //只有 帖子上传到时候才需要这个操作
        String path =
            "https://${DefaultConfig.postImageBucket}.cos.${DefaultConfig.region}.myqcloud.com/$cosPath";
        postContentData.addToPostImagePaths(path);
      }
      completer.complete(true);
    }

    void failCallBack(clientException, serviceException) {
      Logger().e("文件上传失败");
      completer.complete(false);
    }

    TransferTask transferTask = await transferManager.upload(
      bucket,
      cosPath,
      filePath: filePath,
      byteArr: byteArr,
      resultListener: ResultListener(successCallBack, failCallBack),
    );
    transferTask.resume();

    return completer.future;
  }

  Future<bool> imageUpLoad(String imagePath,
      {PostContentData? postContentData}) async {
    String filename = imagePath.split('/').last;
    String cosPath = "${PostContentData.postID}/$filename";
    return uploadFile(DefaultConfig.postImageBucket, cosPath,
        filePath: imagePath, postContentData: postContentData);
  }

  static Future<void> postTextUpLoad(Map map) async {
    TencentUpLoadAndDownload uploader = TencentUpLoadAndDownload();
    String jsonString = json.encode(map);
    Uint8List byte = Uint8List.fromList(utf8.encode(jsonString));

    //发送到全部列表
    bool success = await uploader.uploadFile(
      DefaultConfig.postTextBucket,
      "${PostContentData.postID}.txt",
      byteArr: byte,
    );
    //发送到发帖人的列表
    await uploader.uploadFile(
      DefaultConfig.avatarAndPostBucket,
      "${UserInfoConfig.uniqueID}/post/${PostContentData.postID}.txt",
      byteArr: byte,
    );
    if (success) {
      Loading().hide();
      Logger().i("txt 文件上传成功");
    } else {
      Logger().e("txt 文件上传失败");
    }
  }

  static Future<bool?> userUpLoad(
    BuildContext context,
    String userText, {
    bool modified = false, //是否为更改名称
  }) async {
    TencentUpLoadAndDownload uploader = TencentUpLoadAndDownload();
    String cosPath = "user_info.txt";
    String string = EncryptionHelper.encrypt(userText);
    Uint8List byte = Uint8List.fromList(utf8.encode(string));

    bool success = await uploader
        .uploadFile(DefaultConfig.userInfoBucket, cosPath, byteArr: byte);
    if (success) {
      Logger().i("txt 上传新用户成功");
      if (modified) {
        return true; //如果是修改数据，则不做跳转
      }
      Loading().hide();
      if (context.mounted) Navigator.pushReplacementNamed(context, "/home");
    } else {
      Logger().e("txt 上传新用户失败");
    }
    return null;
  }

  static Future<void> chatUpload(
      String receivedByID, List<Map<String, dynamic>> listMap) async {
    TencentUpLoadAndDownload uploader = TencentUpLoadAndDownload();
    String cosPath1 = "${UserInfoConfig.uniqueID}/$receivedByID.txt";
    String cosPath2 = "$receivedByID/${UserInfoConfig.uniqueID}.txt";

    String jsonString = json.encode(listMap);
    Uint8List byte = Uint8List.fromList(utf8.encode(jsonString));

    await uploader.uploadFile(DefaultConfig.chattingRecordsBucket, cosPath1,
        byteArr: byte);
    await uploader.uploadFile(DefaultConfig.chattingRecordsBucket, cosPath2,
        byteArr: byte);
  }

  static Future<bool> avatarUpLoad(String imagePath) async {
    TencentUpLoadAndDownload uploader = TencentUpLoadAndDownload();
    String cosPath = "${UserInfoConfig.uniqueID}/userAvatar.png";
    return uploader.uploadFile(
      DefaultConfig.avatarAndPostBucket,
      cosPath,
      filePath: imagePath,
    );
  }
}
