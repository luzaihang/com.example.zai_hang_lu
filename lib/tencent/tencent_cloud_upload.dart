import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ci_dong/app_data/app_encryption_helper.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:flutter/material.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';
import 'package:ci_dong/app_data/post_content_config.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';

class TencentCloudUpLoad {
  final Cos cos;
  CosTransferManger transferManager;

  // 构造函数
  TencentCloudUpLoad()
      : cos = CosService().cos,
        transferManager = CosService().cos.getDefaultTransferManger();

  Future<bool> uploadFile(
    String bucket,
    String cosPath, {
    String? filePath,
    Uint8List? byteArr,
    PostContentConfig? postContentData,
    bool? personalFolder,
  }) async {
    Completer<bool> completer = Completer<bool>();

    void successCallBack(result) {
      if (filePath != null && filePath.isNotEmpty && postContentData != null) {
        //只有 帖子上传到时候才需要这个操作
        String path = "${DefaultConfig.postImagePrefix}/$cosPath";
        postContentData.addToPostImagePaths(path);
      }
      if (personalFolder == true && postContentData != null) {
        String path = "${DefaultConfig.personalInfoPrefix}/$cosPath";
        postContentData.personalFolderImagePaths(path);
      }
      completer.complete(true);
    }

    void failCallBack(clientException, serviceException) {
      //().e("文件上传失败");
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
}

///帖子图片上传
Future<bool> imageUpLoad(String imagePath, String postId,
    {PostContentConfig? postContentData}) async {
  TencentCloudUpLoad uploader = TencentCloudUpLoad();
  String filename = imagePath.split('/').last;
  String cosPath = "$postId/$filename";
  return uploader.uploadFile(DefaultConfig.postImageBucket, cosPath,
      filePath: imagePath, postContentData: postContentData);
}

///帖子内容上传，包含图片的链接
Future<void> postTextUpLoad(Map map, String postId, String userId) async {
  TencentCloudUpLoad uploader = TencentCloudUpLoad();
  String jsonString = json.encode(map);
  Uint8List byte = Uint8List.fromList(utf8.encode(jsonString));

//发送到全部列表
  bool success = await uploader.uploadFile(
    DefaultConfig.postTextBucket,
    "$postId.txt",
    byteArr: byte,
  );
//发送到发帖人的列表
  await uploader.uploadFile(
    DefaultConfig.personalInfoBucket,
    "$userId/post/$postId.txt",
    byteArr: byte,
  );
  if (success) {
    Loading().hide();
    //().i("txt 文件上传成功");
  } else {
    Loading().hide();
    //().e("txt 文件上传失败");
  }
}

///用户信息上传,包括全部用户
Future<bool?> userUpLoad(
  BuildContext context,
  String userText, {
  bool modified = false, //是否为更改名称
}) async {
  TencentCloudUpLoad uploader = TencentCloudUpLoad();
  String cosPath = "user_info.txt";
  String string = EncryptionHelper.encrypt(userText); //加密
  Uint8List byte = Uint8List.fromList(utf8.encode(string)); //编码为Uint8List

  bool success = await uploader
      .uploadFile(DefaultConfig.userInfoBucket, cosPath, byteArr: byte);
  if (success) {
    //().i("txt 上传新用户成功");
    if (modified) {
      return true; //如果是修改数据，则不做跳转
    }

    Loading().hide();
    if (context.mounted) Navigator.pushReplacementNamed(context, "/home");
  } else {
    //().e("txt 上传新用户失败");
  }
  return null;
}

///单个人昵称上传,因昵称是可变的，没有服务器，所以只能上传之后下载再更改昵称展示
Future<bool> personalNameUpload(
  String userId,
  String userName,
) async {
  TencentCloudUpLoad uploader = TencentCloudUpLoad();
  String cosPath = "$userId/personal_info.txt";
  Uint8List byte = Uint8List.fromList(utf8.encode(userName));

  bool success = await uploader.uploadFile(
    DefaultConfig.personalInfoBucket,
    cosPath,
    byteArr: byte,
  );
  if (success) {
    //().i("txt 上传personal成功");
    return true;
  } else {
    //().e("txt 上传personal失败");
    return false;
  }
}

///聊天记录上传
Future<void> chatUpload(
    String receivedByID, List<Map<String, dynamic>> listMap) async {
  TencentCloudUpLoad uploader = TencentCloudUpLoad();
  String cosPath1 = "${UserInfoConfig.uniqueID}/$receivedByID.txt";
  String cosPath2 = "$receivedByID/${UserInfoConfig.uniqueID}.txt";

  String jsonString = json.encode(listMap);
  Uint8List byte = Uint8List.fromList(utf8.encode(jsonString));

  await uploader.uploadFile(DefaultConfig.chattingRecordsBucket, cosPath1,
      byteArr: byte);
  await uploader.uploadFile(DefaultConfig.chattingRecordsBucket, cosPath2,
      byteArr: byte);
}

///用户头像上传
Future<String> userAvatarUpLoad(String? imagePath, String userId,
    {Uint8List? uint8list}) async {
  TencentCloudUpLoad tencentUpLoadAndDownload = TencentCloudUpLoad();
  String cosPath = "$userId/userAvatar.png";
  bool result = await tencentUpLoadAndDownload.uploadFile(
    DefaultConfig.personalInfoBucket,
    cosPath,
    filePath: imagePath,
    byteArr: uint8list,
  );

  if (result) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "${DefaultConfig.personalInfoPrefix}/$cosPath?timestamp=$timestamp";
  }

  return '';
}

///用户banner图片上传
Future<bool> bannerImageUpLoad(String imagePath) async {
  TencentCloudUpLoad tencentUpLoadAndDownload = TencentCloudUpLoad();
  String filename = imagePath.split('/').last;
  String cosPath = "${UserInfoConfig.uniqueID}/bannerImgList/$filename";
  return tencentUpLoadAndDownload.uploadFile(
    DefaultConfig.personalInfoBucket,
    cosPath,
    filePath: imagePath,
  );
}

///个人创建文件夹内的，图片上传
Future<bool> personalFolderImageUpLoad(
  String imagePath,
  String folderId,
  String userId,
  PostContentConfig postContentConfig,
) async {
  TencentCloudUpLoad uploader = TencentCloudUpLoad();
  String filename = imagePath.split('/').last;
  String cosPath = "$userId/folderList/images/$folderId/$filename";
  return uploader.uploadFile(
    DefaultConfig.personalInfoBucket,
    cosPath,
    filePath: imagePath,
    postContentData: postContentConfig,
    personalFolder: true,
  );
}

///个人创建文件夹内的，txt上传
Future<bool> personalFolderTxtUpLoad(
  List<Map> txtMap,
  String folderId,
  String userId,
) async {
  TencentCloudUpLoad uploader = TencentCloudUpLoad();
  String cosPath = "$userId/folderList/folder.txt";
  String jsonString = json.encode(txtMap);
  Uint8List byte = Uint8List.fromList(utf8.encode(jsonString));
  return uploader.uploadFile(
    DefaultConfig.personalInfoBucket,
    cosPath,
    byteArr: byte,
  );
}
