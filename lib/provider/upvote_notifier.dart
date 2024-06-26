import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/tencent/tencent_cloud_upload.dart';
import 'package:flutter/material.dart';

///点赞帖子专用provider
class UpvoteNotifier with ChangeNotifier {
  PostDetailFormJson postUpvote(PostDetailFormJson detailFormJson) {
    String postId = detailFormJson.postId ?? ''; //帖子id
    String upvote = detailFormJson.upvote ?? ""; //已经点赞过的人
    String upvotePerson = UserInfoConfig.uniqueID; //现在点赞、取消点赞的人，就是登录人
    Map<String, dynamic> getMap = detailFormJson.toJson();
    String getUp = "";

    if (!upvote.contains(upvotePerson)) {
      //点赞
      getUp = "$upvote|$upvotePerson";
      getMap['upvote'] = getUp;
    } else {
      //取消点赞
      getUp = upvote.replaceAll("|$upvotePerson", '');
      getMap['upvote'] = getUp;
    }

    postTextUpLoad(
      getMap,
      postId,
      detailFormJson.userID ?? "", //点赞帖子时，更新到发帖人的id上
    );

    return PostDetailFormJson.fromJson(getMap);
  }
}
