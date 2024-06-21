import 'dart:convert';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/chat_detail_from_map.dart';

class TencentCloudTxtDownload {
  static final Logger _logger = Logger();

  static Future<String> userInfoTxt() async {
    const url = DefaultConfig.userNameTxtUrl;
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

  static Future<List<ChatDetailFromMap>> chatTxt(String id) async {
    final url = '${DefaultConfig.chattingRecordsPrefix}/${UserInfoConfig.uniqueID}/$id.txt';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final chatDetails = utf8.decode(response.bodyBytes).trim();
        if (chatDetails.isEmpty) {
          return [];
        }
        final List<dynamic> decodedJson = jsonDecode(chatDetails);
        return decodedJson
            .map((data) => ChatDetailFromMap.fromMap(data))
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
