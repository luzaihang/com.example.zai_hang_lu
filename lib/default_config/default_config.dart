///默认设定的数据
class DefaultConfig {
  ///地域
  static const String region = "ap-shanghai";

  ///地域唯一id
  static const String appid = '1322814250';

  ///bucket
  static const String userInfoBucket = "user-info-$appid";
  static const String postTextBucket = "post-text-list-$appid";
  static const String postImageBucket = "post-image-list-$appid";
  static const String chattingRecordsBucket = "chatting-records-$appid";
  static const String avatarAndPostBucket = "user-avatar-post-$appid";

  ///用户没有设置banner图片时
  static const String bannerImg =
      'https://$userInfoBucket.cos.$region.myqcloud.com/default_picture.jpg';

  ///所有用户的信息
  static const String userNameUrl =
      'https://$userInfoBucket.cos.$region.myqcloud.com/user_info.txt';

  ///聊天bucket
  static const String chatText =
      'https://$chattingRecordsBucket.cos.$region.myqcloud.com';

  ///获取banner的图片
  static const String userBannerImg =
      'https://$avatarAndPostBucket.cos.$region.myqcloud.com';
}
