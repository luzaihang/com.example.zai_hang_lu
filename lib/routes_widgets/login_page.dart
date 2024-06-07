import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/loading_page.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_init.dart';
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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoginInfo();
    TenCentCloudInit.initCloud();
  }

  Future<void> _loadLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString("username");
    String? password = prefs.getString("password");

    if (username != null && password != null) {
      setState(() {
        _usernameController.text = username;
        _passwordController.text = password;
      });
    } else {
      Logger().d("No cached username or password found");
    }
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
        onPressed: () async {
          _validateAndLogin(context);
        },
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 100),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: '账号',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey, width: 0.2),
                ),
              ),
              keyboardType: TextInputType.text,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(5),
              cursorColor: Colors.blueGrey,
              style: const TextStyle(color: Colors.blueGrey), // 输入文本后的颜色
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: '密码',
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
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.blueGrey,
                    size: 17.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
              cursorColor: Colors.blueGrey,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(5),
              style: const TextStyle(color: Colors.blueGrey), // 输入文本的颜色
            ),
            const SizedBox(height: 20),
            Row(
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
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '登录、注册协议',
                    style: TextStyle(color: Colors.blue.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndLogin(BuildContext context) async {
    String userName = _usernameController.text;
    String password = _passwordController.text;

    //拼接
    String user = "userName=$userName,password=$password";

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

    String info = await TencentUpLoadAndDownload.userInfoTxt();
    if (info.contains(user)) {
      Loading().hide();
      if (mounted) Navigator.pushNamed(context, "/home");
    } else {
      String upLoadText = "$info$user|";
      if (mounted) TencentUpLoadAndDownload.userUpLoad(context, upLoadText);
    }

    UserInfoConfig.userName = userName;

    // 登录成功后保存账号和密码
    _saveLoginInfo(userName, password);
  }
}