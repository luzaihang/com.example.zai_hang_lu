import 'package:flutter/material.dart';

class User {
  String nickname;
  String password;
  String? userAvatar;

  User({
    required this.nickname,
    required this.password,
    this.userAvatar,
  });
}

class UserProvider with ChangeNotifier {
  User? _user; // 用户对象

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners(); // 通知监听器
  }
}