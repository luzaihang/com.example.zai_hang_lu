import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';

class ClientManager {
  late Client _client;

  // 私有构造函数
  ClientManager._internal();

  // 单例实现
  static final ClientManager _instance = ClientManager._internal();

  // 获取单例实例
  factory ClientManager() {
    return _instance;
  }

  // 初始化Client
  Future<void> initialize() async {
    _client = Client(id: UserInfoConfig.uniqueID);
    try {
      await _client.open();
    } catch (e) {
      //().e(e);
    }
  }

  // 获取Client
  Client get client => _client;
}
