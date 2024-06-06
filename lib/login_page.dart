import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_init.dart';
import 'package:zai_hang_lu/tencent/tencent_upload_download.dart';

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
      // if (mounted) { //
      //   _validateAndLogin(context);
      // }
    } else {
      Logger().d("No cached username or password found");
    }
  }

  Future<void> _saveLoginInfo(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    await prefs.setString("password", password);
    Logger().d("Username saved in cache: $username");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 100),
              const Text(
                'Soul',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 100),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: '账号',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '密码',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _validateAndLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('登录'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  const Text('我已知晓并同意'),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '登录、或直接创建用户',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      _showMessage('账号不能为空');
      return;
    }
    if (password.isEmpty) {
      _showMessage('密码不能为空');
      return;
    }
    if (!_isChecked) {
      _showMessage('请同意用户协议和隐私政策');
      return;
    }

    String info = await TencentUpLoadAndDownload.userInfoTxt();
    if (info.contains(user)) {
      if (mounted) Navigator.pushNamed(context, "/home");
    } else {
      String upLoadText = "$info$user|";
      if(mounted) TencentUpLoadAndDownload.userUpLoad(context, upLoadText);
    }

    // 登录成功后保存账号和密码
    _saveLoginInfo(userName, password);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
