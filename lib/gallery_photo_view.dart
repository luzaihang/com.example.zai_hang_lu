import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:zai_hang_lu/permission_handler.dart';

import 'image_saver.dart';

class GalleryPhotoView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const GalleryPhotoView(
      {super.key, required this.imageUrls, required this.initialIndex});

  @override
  GalleryPhotoViewState createState() => GalleryPhotoViewState();
}

class GalleryPhotoViewState extends State<GalleryPhotoView> {
  late PageController _pageController;
  int dex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        onLongPress: () {
          getShowBottomSheet(context, widget.imageUrls[dex]);
        },
        child: PhotoViewGallery.builder(
          pageController: _pageController,
          itemCount: widget.imageUrls.length,
          builder: (context, index) {
            dex = index;
            return PhotoViewGalleryPageOptions(
              imageProvider:
                  CachedNetworkImageProvider(widget.imageUrls[index]),
            );
          },
        ),
      ),
    );
  }
}

void getShowBottomSheet(BuildContext context, String url, ) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('保存图片'),
            onTap: () {
              Navigator.pop(context);
              ImageSaver.saveImage(context, url);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('取消'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
