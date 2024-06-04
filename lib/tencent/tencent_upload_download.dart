import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';

import '../provider/other_data_provider.dart';

class TencentUpLoadAndDownload {
  ///上传
  void upLoad(String src, OtherDataProvider otherDataProvider) async {
    CosTransferManger transferManager = Cos().getDefaultTransferManger();
    String filename = src.split('/').last; //拿到文件名

    ///下方是参数官网提供、推荐，上方是自定义逻辑
    String cosPath = "${TencentCloudAcquiesceData.contentPrefix}${TencentCloudAcquiesceData.contentName}/$filename"; //对象在存储桶中的位置标识符，即称对象键
    // String cosPath = Uri.encodeFull(string);
    String srcPath = src; //本地文件的绝对路径

    String? uploadId; //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null

    // 上传成功回调
    successCallBack(result) {
      otherDataProvider.getUploadCount();
      Logger().i("todo 文件上传成功");
    }

    //上传失败回调
    failCallBack(clientException, serviceException) {
      otherDataProvider.getUploadCount();
      Logger().e("todo 文件上传失败");
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
        TencentCloudAcquiesceData.bucket!, cosPath,
        filePath: srcPath,
        uploadId: uploadId,
        resultListener: ResultListener(successCallBack, failCallBack),
        stateCallback: stateCallback,
        progressCallBack: progressCallBack,
        initMultipleUploadCallback: initMultipleUploadCallback);
    transferTask.resume();
  }

  //////////////////////////////////////////////////////////////////////////////

  ///下载,对比账号信息
  Future<int> download(String spliceAccount) async {
    /// 状态码 0已注册 1未注册 2其他
    int status = 2;
    Completer<int> completer = Completer<int>();

    /// 读取、写入、删除文件
    Future<void> readWriteAndDeleteFile(String filePath, String text) async {
      // 读取文件
      File file = File(filePath);
      if (!await file.exists()) {
        Logger().i("文件不存在-------------");
        return;
      }

      String fileContent = await file.readAsString();
      if (fileContent.contains(text)) {
        status = 0;
      } else {
        //未注册添加
        await file.writeAsString(spliceAccount, mode: FileMode.append);
        status = await upLoading(filePath);
        file.delete(); //删除
      }
    }

    Future<String> getLocalPath() async {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }

    String localPath = await getLocalPath();

    ///下方是参数官网提供、推荐，上方是自定义逻辑
    CosTransferManger transferManager = Cos().getDefaultTransferManger();
    String cosPath = "name_password.txt"; //对象在存储桶中的位置标识符，即称对象键
    String downloadPath = "$localPath/$cosPath"; //保存到本地文件的绝对路径

    Logger().d(downloadPath);
    // 下载成功回调
    Future<void> successCallBack(result) async {
      Logger().i("下载成功-------------");
      await readWriteAndDeleteFile(downloadPath, spliceAccount);
      completer.complete(status);
    }

    //下载失败回调
    void failCallBack(clientException, serviceException) {
      completer.complete(status);
    }

    //下载状态回调, 可以查看任务过程
    void stateCallback(state) {}
    //下载进度回调
    void progressCallBack(complete, target) {}

    //开始下载
    TransferTask transferTask = await transferManager.download(
        TencentCloudAcquiesceData.bucket!, cosPath, downloadPath,
        resultListener: ResultListener(successCallBack, failCallBack),
        stateCallback: stateCallback,
        progressCallBack: progressCallBack);

    transferTask.resume();

    return completer.future;
  }
}

////////////////////////////////////////////////////////////////////////////////
///这里上传的是保存新用户的休息
Future<int> upLoading(String src) async {
  CosTransferManger transferManager = Cos().getDefaultTransferManger();

  ///下方是参数官网提供、推荐，上方是自定义逻辑
  String cosPath = "name_password.txt"; // 对象在存储桶中的位置标识符，即称对象键
  String srcPath = src; // 本地文件的绝对路径

  // 创建一个Completer，用于等待上传完成的结果
  final Completer<int> completer = Completer<int>();

  // 上传成功回调
  successCallBack(result) {
    Logger().i("todo 上传新用户成功");
    if (!completer.isCompleted) {
      completer.complete(1); // 上传成功返回1
    }
  }

  // 上传失败回调
  failCallBack(clientException, serviceException) {
    Logger().e("todo 上传新用户失败");
    if (!completer.isCompleted) {
      completer.complete(2); // 上传失败返回0
    }
  }

  //开始上传
  TransferTask transferTask = await transferManager.upload(
    TencentCloudAcquiesceData.bucket!,
    cosPath,
    filePath: srcPath,
    resultListener: ResultListener(successCallBack, failCallBack),
  );
  transferTask.resume();

  // 返回Completer的future，等待处理结果
  return completer.future;
}
