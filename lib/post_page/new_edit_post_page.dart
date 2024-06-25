import 'dart:io';

import 'package:ci_dong/app_data/compress_image.dart';
import 'package:ci_dong/main.dart';
import 'package:ci_dong/provider/post_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:provider/provider.dart';

class NewEditPost extends StatefulWidget {
  const NewEditPost({super.key});

  @override
  NewEditPostState createState() => NewEditPostState();
}

class NewEditPostState extends State<NewEditPost> {
  late PostPageNotifier _readNotifier;
  late PostPageNotifier _watchNotifier;

  late ScrollController scrollController;

  CompressImage compressImage = CompressImage();

  //获得得到的图片asset
  List<Asset> _imageAssets = <Asset>[];
  static const int maxImages = 9;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _readNotifier = context.read<PostPageNotifier>();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchNotifier = context.watch<PostPageNotifier>();
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    bool isSelected = true; //进入到相册是否 选择了图片，默认true

    try {
      resultList = await MultiImagePicker.pickImages(
        materialOptions: const MaterialOptions(
          maxImages: 9,
          // startInAllView: true, //这个目前使用之后，没有返回数据
          statusBarColor: Color(0xFF052D84),
          actionBarColor: Color(0xFF052D84),
          actionBarTitle: "选择",
          allViewTitle: "全部",
          useDetailsView: false,
          backButtonDrawable: "@drawable/back_icon",
          selectCircleStrokeColor: Colors.white,
          selectionLimitReachedText: "最多选择9张",
        ),
      );
    } catch (e) {
      appLogger.e(e);
      isSelected = false;
    }

    if (!mounted) return;

    //如果 没有选择图片，则不需要清理
    if (isSelected) _readNotifier.imageFiles.clear();

    _imageAssets = resultList;

    for (var i in _imageAssets) {
      File file = await compressImage.getImageFileFromAsset(i);

      XFile compressedImage = await compressImage.compressImage(file);
      _readNotifier.setImageFiles(compressedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            _buildImageList(),
            _widget(),
            const SizedBox(height: 30),
          ],
        );
      },
    );
  }

  Widget _widget() {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 16, right: 10),
      child: TextField(
        controller: _watchNotifier.postUploadController,
        textAlign: TextAlign.justify,
        decoration: InputDecoration(
          hintText: "把你所遇分享给陌生人吧～",
          hintStyle: TextStyle(color: const Color(0xFF052D84).withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.transparent,
        ),
        maxLines: null,
        minLines: 10,
        cursorColor: const Color(0xFF052D84),
        style: const TextStyle(color: Color(0xFF052D84)),
        strutStyle: const StrutStyle(
          fontSize: 15.0,
          height: 1.7,
        ),
        cursorWidth: 2,
        cursorRadius: const Radius.circular(5),
        onChanged: (text) => _readNotifier.setSubmitText(text),
      ),
    );
  }

  Widget _buildImageList() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 100,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _watchNotifier.imageFiles.length < maxImages
            ? _watchNotifier.imageFiles.length + 1
            : maxImages,
        itemBuilder: (context, index) {
          if (index == _watchNotifier.imageFiles.length) {
            return _buildAddImageButton();
          } else {
            return _buildImageItem(index);
          }
        },
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: loadAssets,
      child: Container(
        margin: EdgeInsets.only(
          left: _watchNotifier.imageFiles.isEmpty ? 20 : 0,
          right: 20,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  color: const Color(0xFF052D84).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
            ),
            Image.asset(
              "assets/image_add_icon.png",
              width: 35,
              height: 35,
              color: const Color(0xFF052D84),
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        index == 0 ? 20 : 0,
        0,
        index == 8 ? 20 : 8,
        0,
      ),
      child: Stack(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_watchNotifier.imageFiles[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: () {
                _readNotifier.removeIndexFiles(index);
              },
              child: Image.asset(
                "assets/image_delete_icon.png",
                width: 16,
                height: 16,
                color: Colors.red.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
