import 'package:flutter/material.dart';
import 'package:zai_hang_lu/app_data/other_data_provider.dart';
import 'package:zai_hang_lu/routes_widgets/post_widget.dart';
import '../tencent/tencent_cloud_list_data.dart';
import 'image_picker_photos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TencentCloudListData tencentCloudListData = TencentCloudListData();
  ImagePickerPhotos imagePickerPhotos = ImagePickerPhotos();
  OtherDataProvider otherDataProvider = OtherDataProvider();

  int dex = 0;

  ///图片列表
  List<String>? imageFiles;

  ///文件夹列表
  List<String>? directories;

  ///底部抽屉
  late AnimationController _controllerDrawer;
  late Animation<double> _animationDrawer;

  ///上传图片
  late AnimationController _controllerUpload;
  late Animation<Offset> _animationUpload;

  @override
  void initState() {
    _onRefresh();
    _drawerInit();
    _uploadInit();
    _uploadToggle();
    super.initState();
  }

  void _uploadInit() {
    _controllerUpload = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    // // 定义一个从左到右的动画
    _animationUpload = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllerUpload,
      curve: Curves.easeInOut,
    ));
  }

  ///监听状态
  void _uploadToggle() {
    otherDataProvider.addListener(() {
      setState(() {
        dex = otherDataProvider.uploadCount;
      });
      if (otherDataProvider.count != otherDataProvider.uploadCount) {
        if (_controllerUpload.isDismissed) {
          _controllerUpload.forward();
        }
      } else {
        if (_controllerUpload.isCompleted) {
          _controllerUpload.reverse();
        }
      }
    });
  }

  void _drawerInit() {
    _controllerDrawer = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _animationDrawer =
        CurvedAnimation(parent: _controllerDrawer, curve: Curves.easeInOut);
  }

  ///抽屉切换
  void _drawerToggle() {
    if (_controllerDrawer.isDismissed) {
      _controllerDrawer.forward();
    } else {
      _controllerDrawer.reverse();
    }
  }

  @override
  void dispose() {
    _controllerDrawer.dispose();
    _controllerUpload.dispose();
    otherDataProvider.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    List<String>? result = await TencentCloudListData.getContentsList();
    directories = result;

    setState(() {});
  }

  Widget floatingAction() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ScaleTransition(
                scale: _animationDrawer,
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: () {
                    otherDataProvider.clean();
                    imagePickerPhotos.loadAssets(context, otherDataProvider);
                  },
                  child: const Icon(Icons.folder),
                ),
              ),
              const SizedBox(height: 10),
              ScaleTransition(
                scale: _animationDrawer,
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, "/editPostPage");
                  },
                  child: const Icon(Icons.refresh_sharp),
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _drawerToggle,
                child: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _controllerDrawer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  final List<Map<String, dynamic>> posts = [
    {
      'username': '明知山有虎',
      'postTime': '41秒以前推荐',
      'location': '云南',
      'message': '32了，有没有95前的？',
      'images': [
        'assets/directories_icon.png',
        'assets/directories_icon.png',
        'assets/directories_icon.png',
        'assets/directories_icon.png',
      ],
    },
    {
      'username': '明知山有虎',
      'postTime': '41秒以前推荐',
      'location': '云南',
      'message': '32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？',
      'images': [
        'assets/directories_icon.png',
        'assets/directories_icon.png',
        'assets/directories_icon.png',
      ],
    },
    {
      'username': '明知山有虎',
      'postTime': '41秒以前推荐',
      'location': '云南',
      'message': '32了，有没有95前的？',
      'images': ['assets/directories_icon.png', 'assets/directories_icon.png'],
    },
    {
      'username': '明知山有虎',
      'postTime': '41秒以前推荐',
      'location': '云南',
      'message': '32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？',
      'images': ['assets/directories_icon.png', 'assets/directories_icon.png'],
    },
    {
      'username': '明知山有虎',
      'postTime': '41秒以前推荐',
      'location': '云南',
      'message': '32了，有没有95前的？',
      'images': ['assets/directories_icon.png', 'assets/directories_icon.png'],
    },
    {
      'username': '明知山有虎',
      'postTime': '41秒以前推荐',
      'location': '云南',
      'message':
          '32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？32了，有没有95前的？',
      'images': ['assets/directories_icon.png'],
    },
    // Add more posts here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingAction(),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostWidget(
            username: post['username'],
            postTime: post['postTime'],
            location: post['location'],
            message: post['message'],
            images: post['images'],
          );
        },
      ),
    );
  }
}
