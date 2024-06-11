import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:ci_dong/tencent/tencent_cloud_acquiesce_data.dart';

class CosService {
  // 创建单例实例
  static final CosService _instance = CosService._internal();

  // Cos 实例
  final Cos cos = Cos();

  // 私有构造函数
  CosService._internal() {
    _initCloud();
    _configureCosXmlService();
  }

  // 提供一个公共访问点
  factory CosService() {
    return _instance;
  }

  /// 初始化腾讯云cos
  void _initCloud() {
    cos.initWithPlainSecret(
      TencentCloudAcquiesceData.secretId,
      TencentCloudAcquiesceData.secretKey,
    );
    Logger().i("腾讯云cos初始化成功");
  }

  /// 注册 COS 服务
  void _configureCosXmlService() {
    final CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
      region: TencentCloudAcquiesceData.region,
      isDebuggable: true,
      isHttps: true,
    );

    cos.registerDefaultService(serviceConfig);

    final TransferConfig transferConfig = TransferConfig(
      forceSimpleUpload: false,
      enableVerification: true,
      divisionForUpload: 4194304, // 设置大于等于 4M 的文件进行分块上传
      sliceSizeForUpload: 2097152, // 设置默认分块大小为 2M
    );

    cos.registerDefaultTransferManger(serviceConfig, transferConfig);
    Logger().i("注册腾讯云COS服务成功");
  }
}