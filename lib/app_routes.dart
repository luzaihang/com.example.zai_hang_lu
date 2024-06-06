import 'package:flutter/material.dart';
import 'package:zai_hang_lu/routes_widgets/home.dart';
import 'routes_widgets/edit_post_page.dart';
import 'login_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String galleryPhotoView = '/galleryPhotoView';
  static const String editPostPage = '/editPostPage';
  static const String loginScreen = '/loginScreen';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      editPostPage: (context) => const EditPostPage(),
      loginScreen: (context) => const LoginScreen(),
    };
  }
}

///查看大图时的传参，使用了命名路由
class GalleryPhotoViewArgs {
  final List<String> imageUrls;
  final int initialIndex;

  GalleryPhotoViewArgs(this.imageUrls, this.initialIndex);
}
