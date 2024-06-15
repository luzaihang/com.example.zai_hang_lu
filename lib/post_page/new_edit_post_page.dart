import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';

class NewEditPost extends StatefulWidget {
  const NewEditPost({super.key});

  @override
  NewEditPostState createState() => NewEditPostState();
}

class NewEditPostState extends State<NewEditPost> {
  final List<File?> _imageFiles = [];

  static const int MAX_IMAGES = 9;

  List<Asset> _images = <Asset>[];

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = '未正确选择图片';

    Logger().i(error);

    try {
      Logger().i(_images);
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: _images,
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

      print("Selected images: $resultList");
    } catch (e) {
      error = e.toString();
      Logger().e(e);
    }

    if (!mounted) return;

    _images = resultList;

    Logger().i(_images);
    for (var i in _images) {
      File file = await getImageFileFromAsset(i);
      _imageFiles.add(file);
    }

    Logger().i(_imageFiles[0]?.path);
    setState(() {});
  }

  Future<File> getImageFileFromAsset(Asset asset) async {
    final byteData = await asset.getByteData();
    final tempFile =
        File('${(await getTemporaryDirectory()).path}/${asset.name}');
    final file = await tempFile.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Column(
            children: [
              _buildImageList(),
              _widget(),
            ],
          );
        },
        childCount: 1,
      ),
    );
  }

  Widget _widget() {
    return Container(
      height: 800,
      margin: const EdgeInsets.only(top: 20, left: 16, right: 10),
      child: TextField(
        textAlign: TextAlign.justify,
        decoration: InputDecoration(
          // labelText: labelText,
          // labelStyle:
          // TextStyle(color: focusNode.hasFocus ? Colors.blueGrey : Colors.grey),
          hintText: "把你所遇分享给陌生人吧～",
          hintStyle: TextStyle(color: const Color(0xFF052D84).withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.transparent,
        ),
        maxLines: null,
        minLines: 1,
        cursorColor: const Color(0xFF052D84),
        style: const TextStyle(color: Color(0xFF052D84)),
        strutStyle: const StrutStyle(
          fontSize: 15.0,
          height: 1.7,
        ),
        cursorWidth: 2,
        cursorRadius: const Radius.circular(5),
        onChanged: (text) {
          setState(() {});
        },
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
        itemCount: _imageFiles.length < MAX_IMAGES
            ? _imageFiles.length + 1
            : MAX_IMAGES,
        itemBuilder: (context, index) {
          if (index == _imageFiles.length) {
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
          left: _imageFiles.isEmpty ? 20 : 0,
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
                File(_imageFiles[index]!.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _imageFiles.removeAt(index);
                });
              },
              child: Image.asset(
                "assets/image_delete_icon.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
