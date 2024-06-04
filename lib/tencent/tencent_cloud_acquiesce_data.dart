class TencentCloudAcquiesceData{

  ///默认id
  static const String appId = "1322814250";

  ///地域
  static late String? region;
  ///bucket
  static late String? bucket;
  ///开发者设置的前缀目录，之后进入到 contentName 最后是 prefix，prefix就是自定义的文件夹名
  static const String contentPrefix = "userContent/";
  ///前缀目录
  static late String? prefix;
  ///默认名称，注册的名称、最大文件夹的名称
  static late String? contentName;
}