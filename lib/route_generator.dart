import 'package:flutter/material.dart';
import 'package:zai_hang_lu/routes_widgets/edit_post_page.dart';
import 'package:zai_hang_lu/routes_widgets/home.dart';
import 'package:zai_hang_lu/routes_widgets/login_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) {
      switch (settings.name) {
        case '/home':
          return const HomePage();
        // 你可以增加更多的路由处理
        case '/editPostPage':
          return const EditPostPage();
        case '/loginScreen':
          return const LoginScreen();
        default:
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
      }
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
