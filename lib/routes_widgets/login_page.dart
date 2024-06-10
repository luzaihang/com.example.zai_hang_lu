import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zai_hang_lu/app_data/random_generator.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/global_component/loading_page.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_service.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_txt_download.dart';
import 'package:zai_hang_lu/tencent/tencent_upload_download.dart';

import '../app_data/show_custom_snackBar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _isChecked = false;
  bool _isPasswordVisible = false;

  final CosService cosService = CosService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoginInfo();
  }

  Future<void> _loadLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString("username") ?? '';
      _passwordController.text = prefs.getString("password") ?? '';
    });
  }

  Future<void> _saveLoginInfo(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    await prefs.setString("password", password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () => _validateAndLogin(context),
        mini: true,
        heroTag: 'loginPageFloatingActionButton',
        child: const Icon(Icons.login_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 100),
            const Text(
              'Second heartbeat',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 100),
            _buildTextField(
              controller: _usernameController,
              hintText: '账号',
              isPassword: false,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              hintText: '密码',
              isPassword: true,
            ),
            const SizedBox(height: 20),
            _buildAgreementSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        border: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey, width: 0.2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.blueGrey,
                  size: 17.0,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      obscureText: isPassword && !_isPasswordVisible,
      cursorColor: Colors.blueGrey,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(5),
      style: const TextStyle(color: Colors.blueGrey),
    );
  }

  Widget _buildAgreementSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Checkbox(
          side: const BorderSide(width: 1.0, color: Colors.blueGrey),
          shape: const CircleBorder(),
          value: _isChecked,
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue.withOpacity(0.7);
            }
            return Colors.transparent;
          }),
          onChanged: (bool? value) {
            setState(() {
              _isChecked = value ?? false;
            });
          },
        ),
        const Text(
          '我已知晓并同意',
          style: TextStyle(color: Colors.blueGrey),
        ),
        TextButton(
          onPressed: () {},
          child: Text('登录、注册协议',
              style: TextStyle(color: Colors.blue.withOpacity(0.7))),
        ),
      ],
    );
  }

  void _validateAndLogin(BuildContext context) async {
    String userName = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (userName.isEmpty) {
      showCustomSnackBar(context, "账号不能为空");
      return;
    }
    if (password.isEmpty) {
      showCustomSnackBar(context, "密码不能为空");
      return;
    }
    if (!_isChecked) {
      showCustomSnackBar(context, "请同意：登录、注册协议");
      return;
    }

    Loading().show(context);
    try {
      String info = await TencentCloudTxtDownload.userInfoTxt();
      LoginGetUserID loginGetUserID = LoginGetUserID();
      List<LoginUser> users = loginGetUserID.parseUsers(info);

      String? userID = loginGetUserID.getUserID(users, userName, password);
      if (userID != null) {
        Logger().i('匹配的UserID是: $userID');
        Loading().hide();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        Logger().e('没有匹配的用户');
        userID = RandomGenerator.getRandomCombination();
        String upLoadText =
            "${info}userName=$userName,password=$password,userID=$userID|";
        if (mounted) TencentUpLoadAndDownload.userUpLoad(context, upLoadText);
      }

      UserInfoConfig.userID = userID;
      UserInfoConfig.userName = userName;

      await _saveLoginInfo(userName, password);
    } catch (e) {
      Logger().e('登录失败：', error: e);
      if (mounted) showCustomSnackBar(context, "登录失败，请稍后重试");
    } finally {
      Loading().hide();
    }
  }
}

class LoginUser {
  String userName;
  String password;
  String userID;

  LoginUser(
      {required this.userName, required this.password, required this.userID});

  factory LoginUser.fromAttributes(List<String> attributes) {
    final Map<String, String> userData = {};
    for (String attribute in attributes) {
      final keyValue = attribute.split('=');
      if (keyValue.length == 2) {
        userData[keyValue[0]] = keyValue[1];
      }
    }
    return LoginUser(
      userName: userData['userName'] ?? '',
      password: userData['password'] ?? '',
      userID: userData['userID'] ?? '',
    );
  }
}

class LoginGetUserID {
  List<LoginUser> parseUsers(String dataString) {
    return dataString
        .split('|')
        .where((userString) => userString.isNotEmpty)
        .map((userString) {
      return LoginUser.fromAttributes(userString.split(','));
    }).toList();
  }

  String? getUserID(List<LoginUser> users, String name, String password) {
    for (LoginUser user in users) {
      if (user.userName == name && user.password == password) {
        return user.userID;
      }
    }
    return null;
  }
}
