import 'dart:io';
import 'package:ci_dong/app_data/post_content_data.dart';
import 'package:ci_dong/app_data/random_generator.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/home_list_data.dart';
import 'package:ci_dong/tencent/tencent_cloud_list_data.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PostPageNotifier with ChangeNotifier {
  TencentUpLoadAndDownload tencentUpLoadAndDownload =
      TencentUpLoadAndDownload();
  PostContentData postContentData = PostContentData();
  TextEditingController controller = TextEditingController();
  TencentCloudListData tencentCloudListData = TencentCloudListData();

  int selectedIndex = 0; //tab下标

  List<UserPost> directories = [];

  //得到图片的具体路径、展示以及提交时使用
  List<String> imageFiles = [];
  String submitText = '';

  Future<void> onRefresh() async {
    directories = await tencentCloudListData.getFirstContentsList() ?? [];
    Logger().i(directories);
    notifyListeners();
  }

  Future<void> onLoadMore() async {
    List<UserPost>? result = await tencentCloudListData.getNextContentsList();
    if (result != null) {
      directories.addAll(result);
      notifyListeners();
    }
  }

  void indexPage(int dex) {
    selectedIndex = dex;
    notifyListeners();
  }

  void setImageFiles(File image) {
    imageFiles.add(image.path);
    notifyListeners();
  }

  void removeIndexFiles(int index) {
    imageFiles.removeAt(index);
    notifyListeners();
  }

  void setSubmitText(String text) {
    submitText = text;
    notifyListeners();
  }

  Future<void> submitButton() async {
    if (controller.text.isEmpty) return;

    PostContentData.postID = RandomGenerator.getRandomCombination();

    if (imageFiles.isNotEmpty) {
      List<Future<bool>> uploadFutures = imageFiles.map((imagePath) {
        return TencentUpLoadAndDownload()
            .imageUpLoad(imagePath, postContentData: postContentData);
      }).toList();

      List<bool> results = await Future.wait(uploadFutures);

      if (results.every((result) => result)) {
        PostDetails postDetails = createPostDetails();
        TencentUpLoadAndDownload.postTextUpLoad(postDetails.toMap());
      }
    } else {
      PostDetails postDetails = createPostDetails();
      TencentUpLoadAndDownload.postTextUpLoad(postDetails.toMap());
    }
  }

  PostDetails createPostDetails() {
    return PostDetails(
      userName: UserInfoConfig.userName,
      userID: UserInfoConfig.uniqueID,
      userAvatar: UserInfoConfig.userAvatar,
      //暂未接入
      location: '',
      postContent: submitText,
      postImages: postContentData.uploadedImagePaths,
      postCreationTime: DateTime.now().toIso8601String(),
    );
  }
}
