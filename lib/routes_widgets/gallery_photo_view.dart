import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPhotoView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  ///查看大图
  const GalleryPhotoView(
      {super.key, required this.imageUrls, required this.initialIndex});

  @override
  GalleryPhotoViewState createState() => GalleryPhotoViewState();
}

class GalleryPhotoViewState extends State<GalleryPhotoView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void systemChromeColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color, // 状态栏背景色
        statusBarIconBrightness: Brightness.light, // 状态栏图标亮度
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // systemChromeColor(Colors.black);
    return WillPopScope(
      onWillPop: ()async{
        // systemChromeColor(const Color(0xFFF2F3F5));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () {
            systemChromeColor(const Color(0xFFF2F3F5));
            Navigator.pop(context);
          },
          child: PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.imageUrls.length,
            loadingBuilder: (context, event) {
              return CustomLoadingIndicator(event: event);
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider:
                    CachedNetworkImageProvider(widget.imageUrls[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  final dynamic event;

  const CustomLoadingIndicator({Key? key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white.withOpacity(0.7),
          backgroundColor: Colors.blueGrey,
          strokeWidth: 2.5,
          strokeCap: StrokeCap.round,
        ),
      );
    }

    final value = event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1);
    return Center(
      child: CircularProgressIndicator(
        value: value,
        color: Colors.white.withOpacity(0.7),
        backgroundColor: Colors.blueGrey,
        strokeWidth: 2.5,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
