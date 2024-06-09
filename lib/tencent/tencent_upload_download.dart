import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';
import 'package:zai_hang_lu/app_data/post_content_data.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/loading_page.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';

class TencentUpLoadAndDownload {
  ///图片上传
  Future<bool> imageUpLoad(String imagePath,
      {PostContentData? postContentData}) async {
    CosTransferManger transferManager = Cos().getDefaultTransferManger();
    String filename = imagePath.split('/').last; //拿到原始文件名

    //提交到bucket的路径,帖子ID为文件夹的昵称
    String cosPath = "${PostContentData.postID}/$filename";
    String srcPath = imagePath; //本地文件的绝对路径

    String? uploadId; //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null

    Completer<bool> completer = Completer<bool>();

    // 上传成功回调
    successCallBack(result) {
      Logger().i("todo 文件上传成功");
      String path =
          "https://${TencentCloudAcquiesceData.postImageBucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/$cosPath";
      postContentData?.addToPostImagePaths(path); //记录上传到哪个位置，已便其他bucket使用
      Logger().d(path);
      Logger().d("=================${postContentData?.uploadedImagePaths}");
      completer.complete(true);
    }

    //上传失败回调
    failCallBack(clientException, serviceException) {
      Logger().e("todo 文件上传失败");
      completer.complete(false);
    }

    //上传状态回调, 可以查看任务过程
    stateCallback(state) {}
    //上传进度回调
    progressCallBack(complete, target) {}
    //初始化分块完成回调
    initMultipleUploadCallback(String bucket, String cosKey, String uploadId) {
      uploadId = uploadId;
    }

    //开始上传
    TransferTask transferTask = await transferManager.upload(
      TencentCloudAcquiesceData.postImageBucket,
      cosPath,
      filePath: srcPath,
      uploadId: uploadId,
      resultListener: ResultListener(successCallBack, failCallBack),
      stateCallback: stateCallback,
      progressCallBack: progressCallBack,
      initMultipleUploadCallback: initMultipleUploadCallback,
    );
    transferTask.resume();

    return completer.future;
  }

  ///帖子文本上传
  static void postTextUpLoad(BuildContext context, Map map) async {
    CosTransferManger transferManager = Cos().getDefaultTransferManger();

    //提交到bucket的路径
    String cosPath = "${PostContentData.postID}.txt";

    // 将map转换为JSON字符串
    String jsonString = json.encode(map);
    // 将JSON字符串转换为Uint8List
    Uint8List byte = Uint8List.fromList(utf8.encode(jsonString));

    String? uploadId; //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null

    // 上传成功回调
    successCallBack(result) {
      Loading().hide();
      if (context.mounted) Navigator.pop(context);
      Logger().i("txt 文件上传成功");
    }

    //上传失败回调
    failCallBack(clientException, serviceException) {
      Logger().e("txt 文件上传失败");
    }

    //上传状态回调, 可以查看任务过程
    stateCallback(state) {}
    //上传进度回调
    progressCallBack(complete, target) {}
    //初始化分块完成回调
    initMultipleUploadCallback(String bucket, String cosKey, String uploadId) {
      uploadId = uploadId;
    }

    //开始上传
    TransferTask transferTask = await transferManager.upload(
      TencentCloudAcquiesceData.postTextBucket,
      cosPath,
      byteArr: byte,
      uploadId: uploadId,
      resultListener: ResultListener(successCallBack, failCallBack),
      stateCallback: stateCallback,
      progressCallBack: progressCallBack,
      initMultipleUploadCallback: initMultipleUploadCallback,
    );
    transferTask.resume();
  }

  ///这里上传的是保存新用户的信息
  static void userUpLoad(BuildContext context, String userText) async {
    CosTransferManger transferManager = Cos().getDefaultTransferManger();

    String cosPath = "user_info.txt"; // 对象在存储桶中的位置标识符，即称对象键

    // 将字符串转换
    Uint8List byte = utf8.encode(userText) as Uint8List;

    // 上传成功回调
    successCallBack(result) {
      Loading().hide();
      Navigator.pushReplacementNamed(context, "/home");
      Logger().i("txt 上传新用户成功");
    }

    // 上传失败回调
    failCallBack(clientException, serviceException) {
      Logger().e("txt 上传新用户失败");
    }

    //开始上传
    TransferTask transferTask = await transferManager.upload(
      TencentCloudAcquiesceData.userInfoBucket,
      cosPath,
      byteArr: byte,
      resultListener: ResultListener(successCallBack, failCallBack),
    );
    transferTask.resume();
  }

  ///聊天发送 receivedByID接收人id
  static void chatUpload(String receivedByID, List<Map<String, dynamic>> listMap) async {
    CosTransferManger transferManager = Cos().getDefaultTransferManger();

    //两人都需同时获得聊天数据
    String cosPath1 = "${UserInfoConfig.userID}/$receivedByID.txt";
    String cosPath2 = "$receivedByID/${UserInfoConfig.userID}.txt";

    String jsonString = json.encode(listMap);
    Uint8List byte = Uint8List.fromList(utf8.encode(jsonString));

    String? uploadId;

    // 上传单个文件的函数
    Future<void> uploadSingleFile(String cosPath) async {
      TransferTask transferTask = await transferManager.upload(
        TencentCloudAcquiesceData.chattingRecordsBucket,
        cosPath,
        byteArr: byte,
        uploadId: uploadId,
        resultListener: ResultListener((result) async {
          Logger().i("$cosPath 文件上传成功");
          if (cosPath == cosPath1) {
            await uploadSingleFile(cosPath2);
          }
        }, (clientException, serviceException) {
          Logger().e("$cosPath 文件上传失败");
        }),
        stateCallback: (state) {},
        progressCallBack: (complete, target) {},
        initMultipleUploadCallback: (bucket, cosKey, uploadId) {
          uploadId = uploadId;
        },
      );
      transferTask.resume();
    }

    // 开始上传 cosPath1
    await uploadSingleFile(cosPath1);
  }
}
