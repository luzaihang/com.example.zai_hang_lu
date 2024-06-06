import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zai_hang_lu/app_data/post_content_data.dart';
import 'package:zai_hang_lu/app_data/random_generator.dart';
import 'package:zai_hang_lu/tencent/tencent_upload_download.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({super.key});

  @override
  EditPostPageState createState() => EditPostPageState();
}

class EditPostPageState extends State<EditPostPage> {
  List<Asset> _images = [];
  final TextEditingController _textController = TextEditingController();

  final FocusNode _contentFocusNode = FocusNode();

  int _textLength = 0;

  void _pickImages() async {
    List<Asset> results = await MultiImagePicker.pickImages(
      materialOptions: const MaterialOptions(
        maxImages: 9,
        statusBarColor: Colors.blueGrey,
        enableCamera: false,
        actionBarColor: Colors.blueGrey,
        actionBarTitle: "已选择",
        allViewTitle: "全部",
        useDetailsView: false,
        selectCircleStrokeColor: Colors.white,
      ),
    );

    setState(() {
      _images = results;
    });
  }

  void _publish() async {
    String text = _textController.text;

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    if (text.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('帖子内容不得超过1000字')),
      );
      return;
    }

    //随机生成帖子ID
    PostContentData.postID = RandomGenerator.getRandomCombination();

    Map<String, dynamic> postDetails = {
      'userName': 'John Doe',
      'userAvatar': 'https://example.com/avatar/johndoe.jpg',
      'location': '云南',
      'postContent': 'Flutter is an open-source UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.',
      'postImages': [
        'https://example.com/images/flutter1.jpg',
        'https://example.com/images/flutter2.jpg',
        'https://example.com/images/flutter3.jpg'
      ],
      'postCreationTime': DateTime.now().toIso8601String() // 生成当前时间的ISO 8601格式字符串
    };
    TencentUpLoadAndDownload.postTextUpLoad(postDetails);

    if (_images.isNotEmpty) {
      for (var image in _images) {
        String path = await getImageFilePath(image);
        Logger().d(path);
        TencentUpLoadAndDownload.imageUpLoad(path);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发布成功')),
      );
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
      fillColor: focusNode.hasFocus ? Colors.blueGrey[50] : Colors.grey[200],
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
        title: const Text('编辑帖子'),
        backgroundColor: Colors.blueGrey,
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
                      if (text.length > 1000) {
                        _textController.text = text.substring(0, 1000);
                        _textController.selection = TextSelection.fromPosition(
                          const TextPosition(offset: 1000),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('帖子内容不可超过1000字')),
                        );
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
                    '$_textLength/1000',
                    style: TextStyle(
                      color: _textLength > 1000 ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            _images.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 6.0,
                      crossAxisSpacing: 6.0,
                    ),
                    itemBuilder: (context, index) {
                      Asset asset = _images[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: AspectRatio(
                              aspectRatio: 1.0, // 1:1 的宽高比
                              child: AssetThumb(
                                asset: asset,
                                width: 300,
                                height: 300,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
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
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.publish),
      ),
    );
  }

  ///图片转换为path
  Future<String> getImageFilePath(Asset asset) async {
    final byteData = await asset.getByteData();
    final buffer = byteData.buffer;

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final filePath = '$tempPath/${asset.name}';
    final file = File(filePath);
    await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file.path;
  }
}
