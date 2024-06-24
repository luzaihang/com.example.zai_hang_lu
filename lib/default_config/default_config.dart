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
  static const String personalInfoBucket = "personal-info-$appid";
  // static const String personalInfoBucket = "personal-info-$appid";

  ///获取所有用户信息的完整链接
  static const String userNameTxtUrl =
      'https://$userInfoBucket.cos.$region.myqcloud.com/user_info.txt';

  ///postTextBucket前缀
  static const String postTextPrefix =
      'https://$postTextBucket.cos.$region.myqcloud.com';

  ///postImageBucket前缀
  static const String postImagePrefix =
      'https://$postImageBucket.cos.$region.myqcloud.com';

  ///chattingRecordsBucket前缀
  static const String chattingRecordsPrefix =
      'https://$chattingRecordsBucket.cos.$region.myqcloud.com';

  ///avatarAndPostBucket前缀
  static const String personalInfoPrefix =
      'https://$personalInfoBucket.cos.$region.myqcloud.com';

  ///personalInfoBucket前缀
  // static const String personalInfoPrefix =
  //     'https://$personalInfoBucket.cos.$region.myqcloud.com';
}
