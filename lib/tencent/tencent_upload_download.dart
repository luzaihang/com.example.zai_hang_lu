import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';
import 'package:zai_hang_lu/app_data/post_content_data.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';
import 'package:http/http.dart' as http;

class TencentUpLoadAndDownload {
  ///图片上传
  Future<bool> imageUpLoad(String imagePath, {PostContentData? postContentData}) async {
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
  static void postTextUpLoad(Map map) async {
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

  ///下载,对比账号信息 spliceAccount对比账号信息
  /*static void download(String spliceAccount) async {
    Future<String> getLocalPath() async {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }

    String localPath = await getLocalPath();

    //https://user-info-1322814250.cos.ap-shanghai.myqcloud.com/user_info.txt

    CosTransferManger transferManager = Cos().getDefaultTransferManger();
    String cosPath = "name_password.txt"; //对象在存储桶中的位置标识符，即称对象键
    String downloadPath = "$localPath/$cosPath"; //保存到本地文件的绝对路径

    // 下载成功回调
    Future<void> successCallBack(result) async {
      Logger().i("下载成功-------------");
    }

    //下载失败回调
    void failCallBack(clientException, serviceException) {
      Logger().i("下载失败-------------");
    }

    //下载状态回调, 可以查看任务过程
    void stateCallback(state) {}
    //下载进度回调
    void progressCallBack(complete, target) {}

    //开始下载
    TransferTask transferTask = await transferManager.download(
      TencentCloudAcquiesceData.userInfoBucket,
      cosPath,
      downloadPath,
      resultListener: ResultListener(successCallBack, failCallBack),
      stateCallback: stateCallback,
      progressCallBack: progressCallBack,
    );

    transferTask.resume();
  }*/

  ///这里上传的是保存新用户的信息
  static void userUpLoad(BuildContext context, String userText) async {
    CosTransferManger transferManager = Cos().getDefaultTransferManger();

    String cosPath = "user_info.txt"; // 对象在存储桶中的位置标识符，即称对象键

    // 将字符串转换
    // Uint8List byte = Uint8List.fromList(utf8.encode(userText));
    Uint8List byte = utf8.encode(userText) as Uint8List;

    // 上传成功回调
    successCallBack(result) {
      Navigator.pushNamed(context, "/home");
      Logger().i("todo 上传新用户成功");
    }

    // 上传失败回调
    failCallBack(clientException, serviceException) {
      Logger().e("todo 上传新用户失败");
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

  static Future<String> userInfoTxt() async {
    const url =
        'https://user-info-1322814250.cos.ap-shanghai.myqcloud.com/user_info.txt';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 获取ResponseBody的字节列表
        List<int> bytes = response.bodyBytes;
        // 解码字节列表为UTF-8字符串
        String info = utf8.decode(bytes);

        if (info.trim().isEmpty) {
          return '';
        }

        Logger().d(info);
        return info;
      } else {
        // 请求失败
        Logger().d("-----------txt异常");
        return '';
      }
    } catch (e) {
      // 异常处理
      Logger().e("$e-----------txt异常");
      return '';
    }
  }
}
