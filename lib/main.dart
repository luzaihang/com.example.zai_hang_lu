import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zai_hang_lu/app_data/app_share_data_provider.dart';
import 'package:zai_hang_lu/route_generator.dart';
import 'routes_widgets/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppShareDataProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
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
        home: const LoginScreen(),
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
