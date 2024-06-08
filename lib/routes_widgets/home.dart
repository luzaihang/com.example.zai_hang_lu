import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:zai_hang_lu/factory_list/home_list_data.dart';
import 'package:zai_hang_lu/pull_to_refresh_list_view.dart';
import 'package:zai_hang_lu/routes_widgets/post_widget.dart';
import '../tencent/tencent_cloud_list_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ///文件列表
  List<UserPost> directories = [];

  TencentCloudListData tencentCloudListData = TencentCloudListData();

  @override
  void initState() {
    _onRefresh();
    super.initState();
  }

  Future<void> _onRefresh() async {
    Logger().d(directories.length);
    List<UserPost>? result = await tencentCloudListData.getFirstContentsList();
    directories = result ?? [];

    setState(() {});
  }

  Future<void> _onLoadMore() async {
    List<UserPost>? result = await tencentCloudListData.getNextContentsList();
    directories.addAll(result ?? []);

    setState(() {});
  }

  String formatDateTimeToMinutes(DateTime dateTime) {
    // 获取当前年份
    int currentYear = DateTime.now().year;

    // 获取日期年份
    int dateYear = dateTime.year;

    // 当年份是今年时，仅显示月、日和时间
    if (dateYear == currentYear) {
      final DateFormat formatter = DateFormat('MM-dd HH:mm');
      return formatter.format(dateTime);
    } else {
      // 否则，显示完整年份、月、日和时间
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          automaticallyImplyLeading: false, // 不显示返回按钮
          title: null, // 不显示标题
          actions: [
            IconButton(
              icon: const Icon(Icons.mail_outline_rounded),
              onPressed: () {},
            ),
          ],
        ),
        body: PullToRefreshListView(
          onRefresh: _onRefresh,
          onLoadMore: _onLoadMore,
          items: directories.map((post) {
            // 使用你之前定义的 PostWidget 组件来渲染每个帖子
            return Container(
              margin:
                  EdgeInsets.only(top: directories.indexOf(post) == 0 ? 12 : 0),
              child: PostWidget(
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
