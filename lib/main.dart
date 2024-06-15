import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/routes_widgets/app_launch_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ci_dong/app_data/app_share_data_provider.dart';
import 'package:ci_dong/global_component/route_generator.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFF2F3F5), // 这里设置状态栏的颜色
      statusBarIconBrightness: Brightness.dark,
    ));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppShareDataProvider()),
        ChangeNotifierProvider(create: (_)=> VisibilityNotifier())
      ],
      child: MaterialApp(
        title: "次动",
        theme: ThemeData(
          brightness: Brightness.light,
          // fontFamily: 'SmileySans',
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        debugShowCheckedModeBanner: false,
        // initialRoute: AppRoutes.splash,
        // routes: AppRoutes.getRoutes(),
        // 使用封装好的路由生成器
        onGenerateRoute: generateRoute,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: NoWaveScrollBehavior(),
            child: child!,
          );
        },
        // home: const LoginScreen(),
        home: const AppLaunchPage(),
      ),
    );
  }
}

// 自定义ScrollBehavior去掉微波颜色效果
class NoWaveScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // 直接返回子项，不添加任何效果
  }
}
