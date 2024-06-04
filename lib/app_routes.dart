import 'package:flutter/material.dart';
import 'package:zai_hang_lu/routes_widgets/home.dart';
import 'package:zai_hang_lu/create_folder.dart';

import 'gallery_photo_view.dart';
import 'login.dart';

class AppRoutes {
  static const String home = '/home';
  static const String loginPage = '/loginPage';
  static const String galleryPhotoView = '/galleryPhotoView';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      loginPage: (context) => const LoginPage(),
    };
  }
}

///查看大图时的传参，使用了命名路由
class GalleryPhotoViewArgs {
  final List<String> imageUrls;
  final int initialIndex;

  GalleryPhotoViewArgs(this.imageUrls, this.initialIndex);
}