import 'package:flutter/material.dart';
import 'package:zai_hang_lu/app_routes.dart';
import 'package:zai_hang_lu/gallery_photo_view.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.galleryPhotoView:
        final args = settings.arguments as GalleryPhotoViewArgs;
        return MaterialPageRoute(
          builder: (context) {
            return GalleryPhotoView(
              imageUrls: args.imageUrls,
              initialIndex: args.initialIndex,
            );
          },
        );
    // 其他路由的处理可以继续添加在这里
    // case '/anotherRoute':
    //   return MaterialPageRoute(builder: (context) => AnotherPage());
      default:
      // 默认情况下返回一个错误页面或者是404页面，这里简化处理用null
        return null;
    }
  }
}