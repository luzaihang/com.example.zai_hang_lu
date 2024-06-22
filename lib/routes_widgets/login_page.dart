import 'package:ci_dong/app_data/app_encryption_helper.dart';
import 'package:ci_dong/global_component/auth_manager.dart';
import 'package:ci_dong/provider/my_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:ci_dong/app_data/random_generator.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/tencent/tencent_cloud_txt_download.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';
import 'package:provider/provider.dart';

import '../app_data/show_custom_snackBar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecked = false;

  late AnimationController _controller;
  late Animation<Offset> _animation;
  late MyPageNotifier _myPageNotifier;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoginInfo();
    _myPageNotifier = context.read<MyPageNotifier>();

    _anima();

    _usernameController.addListener(_onConditionsChanged);
    _passwordController.addListener(_onConditionsChanged);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _anima() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _onConditionsChanged() {
    // 当两个输入框都有内容且复选框被选中时，触发动画；否则反向播放动画
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text.length > 5 &&
        _isChecked) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _onCheckboxChanged(bool newValue) {
    setState(() {
      _isChecked = newValue;
    });
    _onConditionsChanged();
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

  ///默认头像上传
  Future<bool> getUint8(String userId) async {
    try {
      final ByteData data = await rootBundle.load(
        "assets/default_avatar_icon.png",
      );
      Uint8List res = data.buffer.asUint8List();
      await _myPageNotifier.userAvatarUpLoad(null, userId, uint8list: res);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F3F5),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                height: double.infinity,
                width: double.infinity,
                child: Stack(
                  children: [
                    const Text(
                      "登录",
                      style: TextStyle(
                        fontSize: 48,
                        color: Color(0xFF052D84),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Positioned(
                      top: 160,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 0.1))),
                        child: TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            hintText: '输入昵称',
                            border: InputBorder.none,
                            counterText: "",
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey,
                            ),
                          ),
                          // 设置光标颜色
                          cursorColor: const Color(0xFF052D84),
                          // 设置光标的圆角半径
                          cursorRadius: const Radius.circular(5.0),
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFF052D84),
                          ),
                          maxLength: 8,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                  r'[\u4e00-\u9fa5a-zA-Z]'), // 允许输入的字符范围：中文字符和英文字母
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 220,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 0.1))),
                        child: TextField(
                          controller: _passwordController,
                          // obscureText: true, // 设置为密码输入模式
                          keyboardType: TextInputType.number,
                          // 设置为数字键盘
                          decoration: const InputDecoration(
                            hintText: '输入至少6位密码',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            // 去除内边距
                            counterText: "",
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey,
                            ),
                          ),
                          maxLength: 18,
                          // 设置光标颜色
                          cursorColor: const Color(0xFF052D84),
                          // 设置光标的圆角半径
                          cursorRadius: const Radius.circular(5.0),
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFF052D84),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter(
                              RegExp(r'[a-zA-Z0-9]'), // 允许的字符集
                              allow: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              _onCheckboxChanged(!_isChecked);
                            },
                            child: Image.asset(
                              "assets/ok_icon.png",
                              height: 20,
                              color: _isChecked
                                  ? Colors.blue
                                  : Colors.blueGrey.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "点亮",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "确认并同意 ",
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "《用户协议与隐私政策》",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 13),
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Text(
                        "登录即注册  请保管好个人信息",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 350,
                child: SlideTransition(
                  position: _animation,
                  child: GestureDetector(
                    onTap: () {
                      _validateAndLogin(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      decoration: const BoxDecoration(
                        color: Color(0xFF052D84),
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(50)),
                      ),
                      child: const Text(
                        "进入",
                        style: TextStyle(
                          color: Color(0xFFFAFAFA),
                          fontFamily: "JinBuTi",
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndLogin(BuildContext context) async {
    String userName = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (userName.isEmpty) {
      showCustomSnackBar(context, "账号不能为空");
      return;
    }
    if (password.isEmpty && password.length > 5) {
      showCustomSnackBar(context, "密码不能为空、或不足6位");
      return;
    }
    if (!_isChecked) {
      showCustomSnackBar(context, "请同意：登录、注册协议");
      return;
    }

    Loading().show(context);
    try {
      String info = await TencentCloudTxtDownload.userInfoTxt();
      String decryptInfo = "";
      //解码
      if (info.isNotEmpty) {
        decryptInfo = EncryptionHelper.decrypt(info);
      }
      LoginGetUserID loginGetUserID = LoginGetUserID();
      List<LoginUser> users = loginGetUserID.parseUsers(decryptInfo);

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
        Logger().d(decryptInfo);
        String upLoadText =
            "${decryptInfo}userName=$userName,password=$password,userID=$userID|";
        bool res = await getUint8(userID);
        if (mounted && res) {
          TencentUpLoadAndDownload.userUpLoad(context, upLoadText);
        }
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
