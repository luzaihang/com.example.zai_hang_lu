import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';

class TenCentCloudInit {
  /// 初始化腾讯云cos
  static void initCloud() {
    _cloudInit();
    _configureCosXmlService();
  }

  /// 使用永久密钥进行本地调试
  static void _cloudInit() {
    Cos().initWithPlainSecret(
      TencentCloudAcquiesceData.secretId,
      TencentCloudAcquiesceData.secretKey,
    );
    Logger().i("腾讯云cos初始化成功");
  }

  /// 注册 COS 服务
  static void _configureCosXmlService() {
    final CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
      region: TencentCloudAcquiesceData.region,
      isDebuggable: true,
      isHttps: true,
    );

    Cos().registerDefaultService(serviceConfig);

    final TransferConfig transferConfig = TransferConfig(
      forceSimpleUpload: false,
      enableVerification: true,
      divisionForUpload: 4194304, // 设置大于等于 4M 的文件进行分块上传
      sliceSizeForUpload: 2097152, // 设置默认分块大小为 2M
    );

    Cos().registerDefaultTransferManger(serviceConfig, transferConfig);
    Logger().i("注册腾讯云COS服务成功");
  }
}