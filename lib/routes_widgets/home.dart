import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zai_hang_lu/gallery_photo_view.dart';
import '../app_routes.dart';
import '../provider/other_data_provider.dart';
import '../pull_to_refresh_list_view.dart';
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

  ///图片 objectUrls
  List<String>? objectUrls;

  ///底部抽屉
  late AnimationController _controllerDrawer;
  late Animation<double> _animationDrawer;

  ///上传图片
  late AnimationController _controllerUpload;
  late Animation<Offset> _animationUpload;

  @override
  void initState() {
    obj();
    _drawerInit();
    _uploadInit();
    _uploadToggle();
    super.initState();
  }

  Future<void> obj() async {
    objectUrls = await tencentCloudListData.getContentsList();
    setState(() {});
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
    objectUrls = await tencentCloudListData.getContentsList();
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
                  onPressed: () async {},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingAction(),
      body: Stack(
        children: [
          objectUrls != null && objectUrls!.isNotEmpty
              ? PullToRefreshListView(
                  onRefresh: _onRefresh,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 每行展示3个图片
                      // mainAxisSpacing: 12.0, // 主轴方向的间距
                      crossAxisSpacing: 6.0, // 交叉轴方向的间距
                      childAspectRatio: 1, // 宽高比1:1
                    ),
                    itemCount: objectUrls!.length,
                    itemBuilder: (context, index) {
                      bool isFirstRow = index < 3;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.galleryPhotoView,
                            arguments: GalleryPhotoViewArgs(
                              objectUrls!,
                              index,
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: isFirstRow ? 0 : 6.0),
                          // 如果是第一行，top 间距为 0
                          child: CachedNetworkImage(
                            imageUrl: objectUrls![index],
                            placeholder: (context, url) => Container(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : PullToRefreshListView(
                  onRefresh: _onRefresh,
                  child: ListView(
                    children: [
                      Container(
                        color: Colors.transparent,
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: Image.asset("assets/no_file.png",
                          height: 80,),
                        ),
                      )
                    ],
                  ),
                ),
          SlideTransition(
            position: _animationUpload,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(top: 45.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_rounded),
                  const SizedBox(width: 16),
                  Text(
                    "正在上传$dex...",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
