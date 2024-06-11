import 'package:flutter/material.dart';
import 'package:ci_dong/app_data/format_date_time.dart';
import 'package:ci_dong/factory_list/home_list_data.dart';
import 'package:ci_dong/global_component/pull_to_refresh_list_view.dart';
import 'package:ci_dong/widget_element/home_panel_item.dart';
import 'package:ci_dong/widget_element/home_post_item.dart';
import 'package:ci_dong/widget_element/preferredSize_item.dart';
import '../tencent/tencent_cloud_list_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ///文件列表
  List<UserPost> directories = [];

  bool _isPanelVisible = false;

  TencentCloudListData tencentCloudListData = TencentCloudListData();

  @override
  void initState() {
    _onRefresh();
    super.initState();
  }

  Future<void> _onRefresh() async {
    List<UserPost>? result = await tencentCloudListData.getFirstContentsList();
    directories = result ?? [];

    setState(() {});
  }

  Future<void> _onLoadMore() async {
    List<UserPost>? result = await tencentCloudListData.getNextContentsList();
    directories.addAll(result ?? []);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = screenWidth / 2;

    return WillPopScope(
      onWillPop: () => _showExitConfirmationDialog(context),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          onPressed: () async {
            Navigator.pushNamed(context, "/editPostPage");
          },
          mini: true,
          heroTag: 'homePageFloatingActionButton',
          child: const Icon(Icons.edit_calendar_rounded),
        ),
        appBar: preferredSizeWidget(
          AppBar(
            backgroundColor: Colors.blueGrey,
            automaticallyImplyLeading: false, // 不显示返回按钮
            title: null, // 不显示标题
            actions: [
              IconButton(
                icon: const Icon(Icons.mail_outline_rounded),
                onPressed: () => Navigator.pushNamed(context, '/chatListPage'),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  setState(() {
                    _isPanelVisible = !_isPanelVisible;
                  });
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            PullToRefreshListView(
              onRefresh: _onRefresh,
              onLoadMore: _onLoadMore,
              items: directories.map((post) {
                // 使用你之前定义的 PostWidget 组件来渲染每个帖子
                return Container(
                  margin: EdgeInsets.only(
                      top: directories.indexOf(post) == 0 ? 12 : 0),
                  child: HomePostItem(
                    username: post.userName,
                    userID: post.userID ?? '',
                    userAvatar: post.userAvatar,
                    postTime: formatDateTimeToMinutes(post.postCreationTime),
                    location: post.location,
                    message: post.postContent,
                    images: post.postImages,
                  ),
                );
              }).toList(),
            ),
            PanelWidget(
              isVisible: _isPanelVisible,
              panelWidth: panelWidth,
              onClose: () {
                setState(() {
                  _isPanelVisible = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: const Text(
              '退出应用',
              style: TextStyle(color: Colors.blueGrey),
            ),
            content: const Text(
              '你确定要退出应用吗?',
              style: TextStyle(color: Colors.blueGrey),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('取消'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('确定'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
