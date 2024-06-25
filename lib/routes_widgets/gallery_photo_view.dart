import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/default_config/app_system_chrome_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPhotoView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String postId;

  ///查看大图
  const GalleryPhotoView({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    required this.postId,
  });

  @override
  GalleryPhotoViewState createState() => GalleryPhotoViewState();
}

class GalleryPhotoViewState extends State<GalleryPhotoView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    systemChromeColor(Colors.black, Brightness.light);
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        systemChromeColor(const Color(0xFFF2F3F5), Brightness.dark);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            systemChromeColor(const Color(0xFFF2F3F5), Brightness.dark);
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
                imageProvider: CachedNetworkImageProvider(
                  widget.imageUrls[index],
                ),
                // heroAttributes: PhotoViewHeroAttributes(
                //   tag: "post_item${widget.postId}",
                // ),
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
      return const Center(
        child: SpinKitFoldingCube(
          color: Colors.white,
          size: 20.0,
          duration: Duration(milliseconds: 800),
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
