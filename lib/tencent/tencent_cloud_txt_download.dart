import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/factory_list/chat_detail_factory.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';

class TencentCloudTxtDownload {
  static Future<String> userInfoTxt() async {
    const url =
        'https://${TencentCloudAcquiesceData.userInfoBucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/user_info.txt';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 获取ResponseBody的字节列表
        List<int> bytes = response.bodyBytes;
        // 解码字节列表为UTF-8字符串
        String info = utf8.decode(bytes);

        if (info.trim().isEmpty) {
          return '';
        }

        return info;
      } else {
        // 请求失败
        Logger().e("-----------无txt文件，即将创建");
        return '';
      }
    } catch (e) {
      // 异常处理
      Logger().e("$e-----------txt异常2");
      return '';
    }
  }

  static Future<List<ChatDetailSender>> chatTxt(String id) async {
    var url =
        'https://${TencentCloudAcquiesceData.chattingRecordsBucket}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/${UserInfoConfig.userID}/$id.txt';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 获取ResponseBody的字节列表
        List<int> bytes = response.bodyBytes;
        // 解码字节列表为UTF-8字符串
        String chatDetails = utf8.decode(bytes);

        if (chatDetails.trim().isEmpty) {
          return [];
        }

        // 解析JSON字符串为List<Map<String, dynamic>>
        List<dynamic> decodedJson = jsonDecode(chatDetails);

        // 转换为List<ChatDetailSender>
        List<ChatDetailSender> chatList = decodedJson.map((data) {
          return ChatDetailSender.fromMap(data);
        }).toList();

        return chatList;
      } else {
        return [];
      }
    } catch (e) {
      // 异常处理
      Logger().e("$e----------chat-----------txt异常2");
      return [];
    }
  }
}
