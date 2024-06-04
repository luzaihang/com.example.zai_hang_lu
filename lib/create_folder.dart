import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';

import 'tencent/tencent_cloud_acquiesce_data.dart';

class CreateFolder {
  ///注册时自动创建一个文件夹，文件夹名称为注册时的名称
  static void getCreateFolder(String name, BuildContext context,
      {bool initialize = true}) async {
    CosTransferManger transferManager = Cos().getDefaultTransferManger();

    String cosPath() {
      if (initialize) {
        return "${TencentCloudAcquiesceData.contentPrefix}$name/A.txt"; //对象在存储桶中的位置标识符，即称对象键
      } else {
        return "${TencentCloudAcquiesceData.contentPrefix}${TencentCloudAcquiesceData.contentName}$name/A.txt";
      }
    }

    Uint8List byteArray = Uint8List.fromList("001".codeUnits);

    Logger().d(cosPath());

    // 上传成功回调
    successCallBack(result) {
      Logger().i("todo txt上传成功");
      Navigator.pushReplacementNamed(context, '/home');
    }

    //上传失败回调
    failCallBack(clientException, serviceException) {
      Logger().e("todo txt上传失败");
    }

    //上传状态回调, 可以查看任务过程
    stateCallback(state) {
      Logger().i("todo txt上传状态");
    }

    //上传进度回调
    progressCallBack(complete, target) {
      Logger().i("todo txt上传进度");
    }

    //开始上传
    TransferTask transferTask = await transferManager.upload(
      TencentCloudAcquiesceData.bucket!,
      cosPath(),
      byteArr: byteArray,
      resultListener: ResultListener(successCallBack, failCallBack),
      stateCallback: stateCallback,
      progressCallBack: progressCallBack,
    );
    transferTask.resume();
  }
}
