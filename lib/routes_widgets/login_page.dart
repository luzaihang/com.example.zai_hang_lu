import 'dart:convert';

import 'package:ci_dong/app_data/app_encryption_helper.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/factory_list/user_info_from_json.dart';
import 'package:ci_dong/factory_list/user_info_from_map.dart';
import 'package:ci_dong/global_component/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:ci_dong/app_data/random_generator.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/tencent/tencent_cloud_download.dart';
import 'package:ci_dong/tencent/tencent_cloud_upload.dart';

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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoginInfo();

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

  ///默认头像上传,昵称上传到个人
  Future<bool> uploadAvatarAndName(String userId, String userName) async {
    try {
      final ByteData data = await rootBundle.load(
        "assets/default_avatar_icon.png",
      );
      Uint8List res = data.buffer.asUint8List();
      await userAvatarUpLoad(null, userId, uint8list: res);
      await personalNameUpload(userId, userName);
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
    if (password.isEmpty || password.length < 6) {
      showCustomSnackBar(context, "密码不能为空、或不足6位");
      return;
    }
    if (!_isChecked) {
      showCustomSnackBar(context, "请同意：登录、注册协议");
      return;
    }

    Loading().show(context);
    try {
      List userinfoMaps = [];
      String decryptInfo = "";
      bool enroll = false; //是否已经注册
      String userId = ''; //初始化唯一id，下面会赋值

      String info = await TencentCloudTxtDownload.userInfoTxt();
      if (info.isNotEmpty) {
        decryptInfo = EncryptionHelper.decrypt(info); //解密
        userinfoMaps = jsonDecode(decryptInfo); //解码

        for (Map<String, dynamic> item in userinfoMaps) {
          UserInfoFromJson infoItem = UserInfoFromJson.fromJson(item);
          if (infoItem.userName == userName &&
              infoItem.userPassword == password) {
            userId = infoItem.uniqueID; //赋值给它，下方需要缓存起来
            enroll = true;
            break;
          }
        }
      }

      if (enroll) {
        Loading().hide();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        Logger().e('没有匹配的用户');
        userId = RandomGenerator.getRandomCombination();
        bool res = await uploadAvatarAndName(userId, userName); //先设定默认头像，发送到个人信息bucket

        if (!res) {
          //如果上传默认头像失败，则停止执行后面逻辑
          if (mounted) showCustomSnackBar(context, "网络延迟,请稍候再试");
          return;
        }

        UserInfoFromMap userInfoFromMap = UserInfoFromMap(
          userName: userName,
          uniqueID: userId,
          userPassword: password,
          userAvatar:
              "${DefaultConfig.personalInfoPrefix}/$userId/userAvatar.png", //头像默认地址
        );

        userinfoMaps.add(userInfoFromMap.toMap());

        String jsonString = jsonEncode(userinfoMaps); //编码为json,用于加密,准备上传
        Logger().d(userinfoMaps);

        if (mounted && res) {
          userUpLoad(context, jsonString);
        }
      }

      UserInfoConfig.uniqueID = userId;
      UserInfoConfig.userName = userName;
      UserInfoConfig.userPassword = password;

      await AuthManager.login(userName, password, userId);
    } catch (e) {
      Logger().e('登录失败：', error: e);
      if (mounted) showCustomSnackBar(context, "登录失败，请稍后重试");
    } finally {
      Loading().hide();
    }
  }
}
