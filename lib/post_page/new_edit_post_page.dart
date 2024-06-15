import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  ImagePickerWidgetState createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  final List<XFile?> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  static const int MAX_IMAGES = 9;

  List<Asset> images = <Asset>[];
  String _error = 'No Error Detected';

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: images,
        // cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: const MaterialOptions(
          maxImages: 9,
          // actionBarColor: "#abcdef",
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          // selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _buildImageList();
        },
        childCount: 1,
      ),
    );
  }

  Widget _buildImageList() {
    return SizedBox(
      height: 140,
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
      // onTap: _pickImage,
      onTap: loadAssets,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(8.0),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: Image.file(File(_imageFiles[index]!.path), fit: BoxFit.cover),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _imageFiles.removeAt(index);
              });
            },
            child: Container(
              color: Colors.black54,
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickMultiImage();
    if (_imageFiles.length < MAX_IMAGES) {
      setState(() {
        _imageFiles.addAll(pickedFile);
      });
      Logger().i(_imageFiles.length);
    }
  }
}
