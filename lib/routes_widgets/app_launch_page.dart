import 'dart:convert';
import 'package:ci_dong/app_data/app_encryption_helper.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/auth_manager.dart';
import 'package:ci_dong/tencent/tencent_cloud_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// 生成波浪路径的函数
/*Path wavePath(Size size, double animationValue) {
  final path = Path();
  final height = size.height;
  final width = size.width;

  // 修改这些值可以改变波浪的特性
  const waveFrequency = 2.5; // 波浪的频率
  const waveAmplitude = 2.5; // 波浪高度
  final wavePhase = animationValue * 2 * math.pi; // 波浪的相位

  path.lineTo(0, height / 3); // 从左边开始路径，到图片高度的三分之一处

  for (double x = 0; x <= width; x++) {
    double y = height / 3 +
        waveAmplitude *
            math.sin((waveFrequency * x * 2 * math.pi) / width + wavePhase);
    path.lineTo(x, y);
  }

  path.lineTo(width, 0); // 到右上角
  path.lineTo(0, 0); // 到左上角
  path.close();

  return path;
}

// 自定义波浪剪裁器
class WaveClipper extends CustomClipper<Path> {
  final double animationValue;

  WaveClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    return wavePath(size, animationValue);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}*/

class AppLaunchPage extends StatefulWidget {
  const AppLaunchPage({super.key});

  @override
  AppLaunchPageState createState() => AppLaunchPageState();
}

class AppLaunchPageState extends State<AppLaunchPage>
    with SingleTickerProviderStateMixin {
  // late AnimationController _controller;

  final CosService cosService = CosService();

  @override
  void initState() {
    super.initState();

    _loadJsonFile();
    // _animation();
    _isLoggedIn();
  }

  Future<void> _loadJsonFile() async {
    String content = await rootBundle.loadString('assets/tencentCloud.json');
    Map<String, dynamic> parsedContent = json.decode(content);
    String secretId = parsedContent['secretId'] ?? "";
    String secretKey = parsedContent['secretKey'] ?? "";

    String id = EncryptionHelper.decrypt(secretId);
    String key = EncryptionHelper.decrypt(secretKey);

    cosService.initCloud(id, key);
  }

  /*void _animation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // 使动画循环播放
  }*/

  void _isLoggedIn() {
    Future.delayed(const Duration(seconds: 3), () async {
      UserInfoConfig.userName = await AuthManager.getUserName() ?? '';
      UserInfoConfig.userPassword = await AuthManager.getUserPassword() ?? '';
      UserInfoConfig.uniqueID = await AuthManager.getUniqueId() ?? '';

      bool isLoggedIn = await AuthManager.checkLoginStatus();
      if (isLoggedIn) {
        // 跳转到主页
        if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        // 跳转到登录页面
        if (mounted) Navigator.pushReplacementNamed(context, "/loginScreen");
      }
    });
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 120,
              width: 120,
            ),
            /*Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: ClipPath(
                        clipper: WaveClipper(_controller.value),
                        child: Container(
                          height: 120 / 2, // 设置为图片高度的一半
                          width: 105, // 设置为图片的宽度
                          color: const Color(0xFFFAFAFA), // 波浪的背景颜色
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
