import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:zai_hang_lu/app_data/post_content_data.dart';
import 'package:zai_hang_lu/app_data/random_generator.dart';
import 'package:zai_hang_lu/app_data/show_custom_snackBar.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/tencent/tencent_upload_download.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({super.key});

  @override
  EditPostPageState createState() => EditPostPageState();
}

class EditPostPageState extends State<EditPostPage> {
  final TextEditingController _textController = TextEditingController();

  final FocusNode _contentFocusNode = FocusNode();

  PostContentData postContentData = PostContentData();
  final ImagePicker _picker = ImagePicker();

  int _textLength = 0;
  String postContent = "";

  List<XFile>? _imageFiles;
  List<String> _imagePaths = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 800,
        imageQuality: 80,
      );
      setState(() {
        _imageFiles = images;
        _imagePaths = images.map((image) => image.path).toList();
      });
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> uploadImages() async {
    List<Future<bool>> uploadFutures = [];

    for (String imagePath in _imagePaths) {
      uploadFutures.add(
        TencentUpLoadAndDownload()
            .imageUpLoad(imagePath, postContentData: postContentData),
      );
    }

    List<bool> results = await Future.wait(uploadFutures);

    bool allSuccess = results.every((result) => result);

    if (allSuccess) {
      PostDetails postDetails = PostDetails(
        userName: UserInfoConfig.userName,
        userAvatar: postContentData.uploadedImagePaths[0],
        location: '云南',
        postContent: postContent,
        postImages: postContentData.uploadedImagePaths,
        postCreationTime: DateTime.now().toIso8601String(),
      );
      Map getPostText = postDetails.toMap();
      TencentUpLoadAndDownload.postTextUpLoad(getPostText);

      if (mounted) Navigator.pop(context);
    } else {
      Logger().e("部分图片上传失败");
    }
  }

  void _publish() async {
    postContent = _textController.text;

    if (postContent.isEmpty) {
      showCustomSnackBar(context, "请输入内容");
      return;
    }

    if (postContent.length > 520) {
      showCustomSnackBar(context, "帖子内容不得超过520字");
      return;
    }

    //随机生成帖子ID
    PostContentData.postID = RandomGenerator.getRandomCombination();

    if (_imagePaths.isNotEmpty) {
      postContentData.prepareForNewPost();

      uploadImages();
    } else {
      PostDetails postDetails = PostDetails(
        userName: UserInfoConfig.userName,
        userAvatar: "",
        location: '云南',
        postContent: postContent,
        postImages: [],
        postCreationTime: DateTime.now().toIso8601String(),
      );
      Map getPostText = postDetails.toMap();
      TencentUpLoadAndDownload.postTextUpLoad(getPostText);

      if (mounted) Navigator.pop(context);
    }
  }

  InputDecoration _getInputDecoration(
      {required String labelText, required FocusNode focusNode}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? Colors.blueGrey : Colors.grey,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      // 设置默认提示词颜色
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      filled: true,
      fillColor: focusNode.hasFocus ? Colors.blueGrey[50] : Colors.grey[520],
      // 设置输入框颜色
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.blueGrey,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const ImageIcon(
            AssetImage("assets/back_icon.png"),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImages,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextField(
                  controller: _textController,
                  focusNode: _contentFocusNode,
                  decoration: _getInputDecoration(
                      labelText: '输入帖子内容', focusNode: _contentFocusNode),
                  maxLines: null,
                  // 允许输入多行
                  cursorColor: Colors.blueGrey,
                  style: const TextStyle(color: Colors.blueGrey),
                  strutStyle: const StrutStyle(
                    fontSize: 16.0,
                    height: 1.5, // 设置字间距
                  ),
                  onChanged: (text) {
                    setState(() {
                      _textLength = text.length;
                      if (text.length > 520) {
                        _textController.text = text.substring(0, 520);
                        _textController.selection = TextSelection.fromPosition(
                          const TextPosition(offset: 520),
                        );
                        showCustomSnackBar(context, "帖子内容不可超过520字");
                      }
                    });
                  },
                  onTap: () {
                    setState(() {});
                  },
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Text(
                    '$_textLength/520',
                    style: TextStyle(
                      color: _textLength > 520 ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            _imageFiles != null
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _imageFiles!.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 6.0,
                      crossAxisSpacing: 6.0,
                    ),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Image.file(
                              File(_imageFiles![index].path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 8.0,
                            left: 8.0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _imageFiles?.removeAt(index);
                                  _imagePaths.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.blueGrey,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _publish,
        mini: true,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.publish),
      ),
    );
  }
}
