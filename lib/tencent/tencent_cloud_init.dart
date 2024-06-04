import 'package:logger/logger.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_list_data.dart';
class TenCentCloudInit {

  ///腾讯云cos初始化
  // void cloudInit(){
  //   plainSecret();
  //   cosXmlServiceConfig();
  // }

  ///使用永久密钥进行本地调试
  void cloudInit(){
    Cos().initWithPlainSecret(TencentCloudAcquiesceData.secretId, TencentCloudAcquiesceData.secretKey);
    Logger().i("腾讯云cos初始化---------------成功");
  }

  ///注册 COS 服务
  void cosXmlServiceConfig (){
    // 存储桶所在地域简称，例如广州地区是 ap-guangzhou
    // String region = "ap-shanghai";
    // 创建 CosXmlServiceConfig 对象，根据需要修改默认的配置参数
    CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
      region: TencentCloudAcquiesceData.region,
      isDebuggable: true,
      isHttps: true,
    );
    // 注册默认 COS Service
    Cos().registerDefaultService(serviceConfig);

    // 创建 TransferConfig 对象，根据需要修改默认的配置参数
    // TransferConfig 可以设置智能分块阈值 默认对大于或等于2M的文件自动进行分块上传，可以通过如下代码修改分块阈值
    TransferConfig transferConfig = TransferConfig(
      forceSimpleUpload: false,
      enableVerification: true,
      divisionForUpload: 4194304, // 设置大于等于 4M 的文件进行分块上传
      sliceSizeForUpload: 2097152, //设置默认分块大小为 2M
    );
    // 注册默认 COS TransferManger
    Cos().registerDefaultTransferManger(serviceConfig, transferConfig);
    Logger().i("注册腾讯云COS服务--------------成功");

    // 也可以通过 registerService 和 registerTransferManger 注册其他实例， 用于后续调用
    // 一般用 region 作为注册的 key
    // String newRegion = "NEW_COS_REGION";
    // Cos().registerService(newRegion, serviceConfig..region = newRegion);
    // Cos().registerTransferManger(newRegion, serviceConfig..region = newRegion, transferConfig);
  }
}