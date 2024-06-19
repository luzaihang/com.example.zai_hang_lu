import 'dart:io';
import 'package:ci_dong/app_data/post_content_data.dart';
import 'package:ci_dong/app_data/random_generator.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/home_list_data.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/tencent/tencent_cloud_list_data.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PostPageNotifier with ChangeNotifier {
  TencentUpLoadAndDownload tencentUpLoadAndDownload =
      TencentUpLoadAndDownload();
  PostContentData postContentData = PostContentData();
  TextEditingController postUploadController = TextEditingController();
  TencentCloudListData tencentCloudListData = TencentCloudListData();

  int selectedIndex = 0; //tab下标

  List<UserPost> allTabList = [];
  List<UserPost> userTabList = [];

  //得到图片的具体路径、展示以及提交时使用
  List<String> imageFiles = [];
  String submitText = '';

  Alignment alignment = Alignment.centerLeft;

  Future<void> onAllRefresh() async {
    allTabList = await tencentCloudListData.getAllFirstContentsList() ?? [];
    notifyListeners();
  }

  Future<void> onAllLoadMore() async {
    List<UserPost>? result = await tencentCloudListData.getAllNextContentsList();
    if (result != null) {
      allTabList.addAll(result);
      notifyListeners();
    }
  }

  Future<void> onUserRefresh() async {
    userTabList = await tencentCloudListData.getUserPostFirstContentsList() ?? [];
    notifyListeners();
  }

  Future<void> onUserLoadMore() async {
    List<UserPost>? result = await tencentCloudListData.getUserPostNextContentsList();
    if (result != null) {
      userTabList.addAll(result);
      notifyListeners();
    }
  }

  void indexPage(int dex) {
    selectedIndex = dex;
    notifyListeners();
  }

  void onTabTapped(VisibilityNotifier visibilityNotifier, int index) {
    indexPage(index);

    switch (index) {
      case 0:
        alignment = Alignment.centerLeft;
        visibilityNotifier.updateVisibility(true);
        break;
      case 1:
        alignment = Alignment.center;
        visibilityNotifier.updateVisibility(true);
        break;
      case 2:
        alignment = Alignment.centerRight;
        visibilityNotifier.updateVisibility(false);
        break;
    }
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

  Future<void> submitButton(BuildContext context) async {
    if (postUploadController.text.isEmpty) return;

    Loading().show(context);

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

    cleanContent();
  }

  void cleanContent() {
    submitText = '';
    postUploadController.clear();
    imageFiles.clear();

    ///发布成功返回到个人列表页
    alignment = Alignment.center;
    indexPage(1);
    postContentData.prepareForNewPost();
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
