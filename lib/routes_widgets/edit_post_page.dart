import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ci_dong/app_data/post_content_data.dart';
import 'package:ci_dong/app_data/random_generator.dart';
import 'package:ci_dong/app_data/show_custom_snackBar.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/loading_page.dart';
import 'package:ci_dong/global_component/show_custom_dialog.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';
import 'package:ci_dong/widget_element/preferredSize_item.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({super.key});

  @override
  EditPostPageState createState() => EditPostPageState();
}

class EditPostPageState extends State<EditPostPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final PostContentData _postContentData = PostContentData();

  int _textLength = 0;
  String _postContent = "";

  List<XFile>? _imageFiles;
  List<String> _imagePaths = [];

  Future<void> _pickImages() async {
    bool? res = await showCustomDialog(context, "是否同意进入到相册选择图片");
    if (res != true) return;
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      setState(() {
        _imageFiles = images;
        _imagePaths = images.map((image) => image.path).toList();
      });
    } catch (e) {
      if (mounted) showCustomSnackBar(context, "图片选择失败");
    }
  }

  Future<void> _uploadImages() async {
    List<Future<bool>> uploadFutures = _imagePaths.map((imagePath) {
      return TencentUpLoadAndDownload()
          .imageUpLoad(imagePath, postContentData: _postContentData);
    }).toList();

    List<bool> results = await Future.wait(uploadFutures);

    if (results.every((result) => result)) {
      PostDetails postDetails = _createPostDetails();
      if (mounted) {
        TencentUpLoadAndDownload.postTextUpLoad(context, postDetails.toMap());
      }
    } else {
      if (mounted) showCustomSnackBar(context, "部分图片上传失败");
    }
  }

  PostDetails _createPostDetails() {
    return PostDetails(
      userName: UserInfoConfig.userName,
      userID: UserInfoConfig.uniqueID,
      userAvatar: _postContentData.uploadedImagePaths.isNotEmpty
          ? _postContentData.uploadedImagePaths[0]
          : "",
      location: '云南',
      postContent: _postContent,
      postImages: _postContentData.uploadedImagePaths,
      postCreationTime: DateTime.now().toIso8601String(),
    );
  }

  void _publish() async {
    _postContent = _textController.text;

    if (_postContent.isEmpty) {
      showCustomSnackBar(context, "请输入内容");
      return;
    }

    if (_postContent.length > 520) {
      showCustomSnackBar(context, "帖子内容不得超过520字");
      return;
    }

    Loading().show(context);

    PostContentData.postID = RandomGenerator.getRandomCombination();

    if (_imagePaths.isNotEmpty) {
      _postContentData.prepareForNewPost();
      await _uploadImages();
    } else {
      PostDetails postDetails = _createPostDetails();
      if (mounted) {
        TencentUpLoadAndDownload.postTextUpLoad(context, postDetails.toMap());
      }
    }
  }

  InputDecoration _getInputDecoration(
      {required String labelText, required FocusNode focusNode}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle:
          TextStyle(color: focusNode.hasFocus ? Colors.blueGrey : Colors.grey),
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      filled: true,
      fillColor: focusNode.hasFocus ? Colors.blueGrey[50] : Colors.grey[50],
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget _buildImageGrid() {
    return _imageFiles != null
        ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _imageFiles!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: preferredSizeWidget(
          AppBar(
            backgroundColor: Colors.blueGrey,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const ImageIcon(AssetImage("assets/back_icon.png")),
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
                    cursorColor: Colors.blueGrey,
                    style: const TextStyle(color: Colors.blueGrey),
                    strutStyle: const StrutStyle(fontSize: 16.0, height: 1.5),
                    cursorWidth: 2,
                    cursorRadius: const Radius.circular(5),
                    onChanged: (text) {
                      setState(() {
                        _textLength = text.length;
                        if (text.length > 520) {
                          _textController.text = text.substring(0, 520);
                          _textController.selection =
                              TextSelection.fromPosition(
                                  const TextPosition(offset: 520));
                          showCustomSnackBar(context, "帖子内容不可超过520字");
                        }
                      });
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
              _buildImageGrid(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _publish,
          mini: true,
          backgroundColor: Colors.blueGrey,
          heroTag: 'editPostFloatingActionButton',
          child: const Icon(Icons.publish_rounded),
        ),
      ),
    );
  }
}
