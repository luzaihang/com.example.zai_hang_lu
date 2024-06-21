import 'package:ci_dong/routes_widgets/app_launch_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ci_dong/routes_widgets/chat_detail_page.dart';
import 'package:ci_dong/routes_widgets/chat_list_page.dart';
import 'package:ci_dong/routes_widgets/gallery_photo_view.dart';
import 'package:ci_dong/routes_widgets/home_page.dart';
import 'package:ci_dong/routes_widgets/login_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  var arguments = settings.arguments;

  Widget getPage() {
    switch (settings.name) {
      case '/home':
        return const HomePage();
      case '/loginScreen':
        return const LoginScreen();
      case '/appLaunchPage':
        return const AppLaunchPage();
      case "/galleryPhotoView":
        if (arguments is GalleryPhotoViewArguments) {
          return GalleryPhotoView(
              imageUrls: arguments.imageUrls,
              initialIndex: arguments.initialIndex);
        } else {
          return _errorRoute('No arguments provided for GalleryPhotoView');
        }
      case "/chatListPage":
        return const ChatListPage();
      case "/chatDetailPage":
        if (arguments is ChatDetailPageArguments) {
          return ChatDetailPage(
            taUserName: arguments.taUserName,
            taUserID: arguments.taUserID,
            taUserAvatar: arguments.taUserAvatar,
          );
        } else {
          return _errorRoute('No arguments provided for ChatDetailPage');
        }
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  return CupertinoPageRoute(
    builder: (context) => getPage(),
    settings: settings,
  );
}

Widget _errorRoute(String message) {
  return Scaffold(
    body: Center(
      child: Text(message),
    ),
  );
}

class GalleryPhotoViewArguments {
  final List<String> imageUrls;
  final int initialIndex;

  GalleryPhotoViewArguments(
      {required this.imageUrls, required this.initialIndex});
}

class ChatDetailPageArguments {
  final String taUserName;
  final String taUserAvatar;
  final String taUserID;

  ChatDetailPageArguments({
    required this.taUserName,
    required this.taUserAvatar,
    required this.taUserID,
  });
}
