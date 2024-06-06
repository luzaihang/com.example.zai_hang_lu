import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserInfoSave {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user_info.txt');
  }
  ///写入用户信息
  Future<File> writeUserInfo(String info) async {
    final file = await _localFile;
    return file.writeAsString(info);
  }
  ///读取用户信息
  Future<String> readUserInfo() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }
}
