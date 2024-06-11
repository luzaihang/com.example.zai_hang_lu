import 'package:ci_dong/global_component/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ci_dong/app_data/random_generator.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/global_component/show_custom_dialog.dart';
import 'package:ci_dong/tencent/tencent_cloud_txt_download.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';

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
  }

  Future<void> _loadLoginInfo() async {
    String? userName = await AuthManager.getUserName();
    String? userPassword = await AuthManager.getUserPassword();
    // String? userAvatar = await AuthManager.getUserAvatar();
    // String? uniqueID = await AuthManager.getUniqueId();

    setState(() {
      _usernameController.text = userName ?? '';
      _passwordController.text = userPassword ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          onPressed: () async {
            bool? res = await showCustomDialog(context, "登录即代表注册，请记住个人信息");
            if (res != true) return;
            if (mounted) _validateAndLogin(context);
          },
          mini: true,
          heroTag: 'loginPageFloatingActionButton',
          child: const Text(
            "登录",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFFAFAFA),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 100),
              Image.asset("assets/logo.png", height: 70),
              const SizedBox(height: 10),
              const Text(
                'Second heartbeat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 100),
              _buildTextField(
                controller: _usernameController,
                hintText: '账号最多8位',
                isPassword: false,
                maxLength: 8,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                hintText: '密码最多18位',
                isPassword: true,
                maxLength: 18,
              ),
              const SizedBox(height: 20),
              _buildAgreementSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    required int maxLength,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
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
      maxLength: maxLength,
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
          child: Text('《隐私政策和条款》',
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

      UserInfoConfig.uniqueID = userID;
      UserInfoConfig.userName = userName;
      UserInfoConfig.userPassword = password;

      await AuthManager.login(userName, password, userID);
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
