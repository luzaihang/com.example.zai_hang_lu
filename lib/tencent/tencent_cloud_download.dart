import 'dart:convert';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/factory_list/personal_folder_from_map.dart';
import 'package:ci_dong/main.dart';
import 'package:http/http.dart' as http;
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/chat_detail_from_map.dart';

class TencentCloudTxtDownload {

  ///全部用户信息获取
  static Future<String> userInfoTxt() async {
    const url = DefaultConfig.userNameTxtUrl;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final info = utf8.decode(response.bodyBytes).trim(); //解码Uint8List
        return info.isEmpty ? '' : info; //输出
      } else {
        return '';
      }
    } catch (e) {
      appLogger.e(e);
      return '';
    }
  }

  ///聊天记录获取
  static Future<List<ChatDetailFromMap>> chatTxt(String id) async {
    final url =
        '${DefaultConfig.chattingRecordsPrefix}/${UserInfoConfig.uniqueID}/$id.txt';
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
      appLogger.e(e);
      return [];
    }
  }

  ///用户昵称获取,因昵称是可变的，没有服务器，所以只能上传之后下载再更改昵称展示
  static Future<String> personalName(String id) async {
    final url = '${DefaultConfig.personalInfoPrefix}/$id/personal_info.txt';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final name = utf8.decode(response.bodyBytes).trim();
        if (name.isNotEmpty) {
          return name;
        }
      }
    } catch (e) {
      appLogger.e(e);
      return "";
    }
    return "";
  }

  ///personal文件夹的txt文件，里面包含所有的文件夹信息详情，
  ///得到这个，就等于得到了个人图册文件夹的所有信息
  static Future<List<PersonalFolderFromMap>> personalFolderImages(
      String id) async {
    final url = '${DefaultConfig.personalInfoPrefix}/$id/folderList/folder.txt';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = utf8.decode(response.bodyBytes).trim();
        List<dynamic> decodedList = jsonDecode(result);
        List<Map<String, dynamic>> listMap =
            List<Map<String, dynamic>>.from(decodedList);
        appLogger.d(listMap);
        List<PersonalFolderFromMap> listPersonalFolder =
            listMap.map((map) => PersonalFolderFromMap.fromMap(map)).toList();
        return listPersonalFolder;
      } else {
        return [];
      }
    } catch (e) {
      appLogger.e(e);
      return [];
    }
  }
}
