import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/chat_detail_factory.dart';
import 'package:ci_dong/tencent/tencent_cloud_acquiesce_data.dart';

class TencentCloudTxtDownload {
  static final Logger _logger = Logger();

  static Future<String> userInfoTxt() async {
    const url =
        'https://${TencentCloudAcquiesceData.userInfoBucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/user_info.txt';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final info = utf8.decode(response.bodyBytes).trim();
        return info.isEmpty ? '' : info;
      } else {
        _logger.e("-----------无txt文件，即将创建");
        return '';
      }
    } catch (e) {
      _logger.e("$e-----------txt异常2");
      return '';
    }
  }

  static Future<List<ChatDetailSender>> chatTxt(String id) async {
    final url =
        'https://${TencentCloudAcquiesceData.chattingRecordsBucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/${UserInfoConfig.uniqueID}/$id.txt';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final chatDetails = utf8.decode(response.bodyBytes).trim();
        if (chatDetails.isEmpty) {
          return [];
        }
        final List<dynamic> decodedJson = jsonDecode(chatDetails);
        return decodedJson
            .map((data) => ChatDetailSender.fromMap(data))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      _logger.e("$e----------chat-----------txt异常2");
      return [];
    }
  }
}
