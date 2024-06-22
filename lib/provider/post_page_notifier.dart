import 'dart:io';
import 'package:ci_dong/app_data/post_content_config.dart';
import 'package:ci_dong/app_data/random_generator.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/factory_list/post_detail_from_map.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/tencent/tencent_cloud_list_data.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PostPageNotifier with ChangeNotifier {
  TencentUpLoadAndDownload tencentUpLoadAndDownload =
      TencentUpLoadAndDownload();
  PostContentConfig postContentData = PostContentConfig();
  TextEditingController postUploadController = TextEditingController();
  TencentCloudListData tencentCloudListData = TencentCloudListData();
  RefreshController allRefreshController =
      RefreshController(initialRefresh: false);
  RefreshController userRefreshController =
      RefreshController(initialRefresh: false);

  String postId = ""; //帖子id

  int selectedIndex = 0; //tab下标

  List<PostDetailFormJson> allTabList = [];
  List<PostDetailFormJson> userTabList = [];

  //得到图片的具体路径、展示以及提交时使用
  List<String> imageFiles = [];
  String submitText = '';

  Alignment alignment = Alignment.centerLeft;

  Future<void> onAllRefresh() async {
    allTabList = await tencentCloudListData.getAllFirstContentsList() ?? [];
    allRefreshController.refreshCompleted();
    notifyListeners();
  }

  Future<void> onAllLoadMore() async {
    List<PostDetailFormJson>? result =
        await tencentCloudListData.getAllNextContentsList();
    if (result != null) {
      allTabList.addAll(result);
      allRefreshController.loadComplete();
      notifyListeners();
    }
  }

  Future<void> onUserRefresh() async {
    userTabList =
        await tencentCloudListData.getUserPostFirstContentsList() ?? [];
    userRefreshController.refreshCompleted();
    notifyListeners();
  }

  Future<void> onUserLoadMore() async {
    List<PostDetailFormJson>? result =
        await tencentCloudListData.getUserPostNextContentsList();
    if (result != null) {
      userTabList.addAll(result);
      userRefreshController.loadComplete();
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

    postId = RandomGenerator.getRandomCombination();

    if (imageFiles.isNotEmpty) {
      List<Future<bool>> uploadFutures = imageFiles.map((imagePath) {
        //帖子图片上传，上传完之后将所有数据集中，再执行 postTextUpload()
        return TencentUpLoadAndDownload()
            .imageUpLoad(imagePath, postId, postContentData: postContentData);
      }).toList();

      List<bool> results = await Future.wait(uploadFutures);

      if (results.every((result) => result)) {
        postTextUpload();
      }
    } else {
      postTextUpload();
    }

    cleanContent();
  }

  ///帖子内容上传
  void postTextUpload() {
    PostDetailFromMap postDetails = createPostDetail();
    TencentUpLoadAndDownload.postTextUpLoad(
      postDetails.toMap(),
      postId,
      UserInfoConfig.uniqueID, //帖子发布时是自己的id
    );
  }

  PostDetailFromMap createPostDetail() {
    return PostDetailFromMap(
      userName: UserInfoConfig.userName,
      userID: UserInfoConfig.uniqueID,
      userAvatar: UserInfoConfig.userAvatar,
      //暂未接入
      location: '',
      postContent: submitText,
      postImages: postContentData.uploadedImagePaths,
      postCreationTime: DateTime.now().toIso8601String(),
      upvote: '',
      postId: postId,
    );
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

  ///更新帖子点赞状态
  void updatePostUpvote(String id, PostDetailFormJson item) {
    int indexAllTab = allTabList.indexWhere((post) => post.postId == id);
    int indexUserTab = userTabList.indexWhere((post) => post.postId == id);

    if (indexAllTab != -1) {
      allTabList[indexAllTab] = item;
    }

    if (indexUserTab != -1) {
      userTabList[indexUserTab] = item;
    }

    notifyListeners();
  }
}
