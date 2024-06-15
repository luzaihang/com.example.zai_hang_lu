import 'package:ci_dong/lean_cloud/client_manager.dart';
import 'package:ci_dong/my_page/my_main.dart';
import 'package:ci_dong/post_page/post_main.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:flutter/material.dart';
import 'package:ci_dong/app_data/format_date_time.dart';
import 'package:ci_dong/factory_list/home_list_data.dart';
import 'package:ci_dong/global_component/pull_to_refresh_list_view.dart';
import 'package:ci_dong/widget_element/home_panel_item.dart';
import 'package:ci_dong/widget_element/home_post_item.dart';
import 'package:ci_dong/widget_element/preferredSize_item.dart';
import 'package:flutter/rendering.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../tencent/tencent_cloud_list_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ///文件列表
  List<UserPost> directories = [];

  bool _isPanelVisible = false;

  TencentCloudListData tencentCloudListData = TencentCloudListData();

  bool newMessage = false;
  bool _isActive = true;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _leanCloudInit();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 初始状态设定
    // 按需调用以下代码
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisibilityNotifier>().updateVisibility(true);
      // 确保动画控制器初始即启动
      _controller.forward();
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isActive = state == AppLifecycleState.resumed;
  }

  void _toggleBottomNavigationBar(bool isVisible) {
    if (isVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _leanCloudInit() async {
    await ClientManager().initialize();

    Client client = ClientManager().client;
    client.onUnreadMessageCountUpdated = ({
      required Client client,
      required Conversation conversation,
    }) {
      Logger().i(conversation.id);
    };
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

  int _currentIndex = 0;
  final List<Widget> _children = [
    const MyMain(),
    const PostMain(),
    ProfileScreen(),
  ];

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildImageIcon(
      double bot, String assetName, Color? color, double height) {
    return Container(
      margin: EdgeInsets.only(bottom: bot),
      child: Image.asset(
        assetName,
        width: height,
        height: height,
        color: color,
      ), // 根据需求调整尺寸
    );
  }

  @override
  Widget build(BuildContext context) {

    final visibilityNotifier = Provider.of<VisibilityNotifier>(context);

    visibilityNotifier.addListener(() {
      _toggleBottomNavigationBar(visibilityNotifier.isVisible);
    });

    return WillPopScope(
      onWillPop: () => _showExitConfirmationDialog(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F3F5),
        body:
        Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _children,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _offsetAnimation,
                child: BottomNavigationBar(
                  onTap: onTappedBar,
                  currentIndex: _currentIndex,
                  selectedItemColor: const Color(0xFF1E3A8A),
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "JinBuTi",
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12.0,
                    fontFamily: "JinBuTi",
                  ),
                  type: BottomNavigationBarType.shifting,
                  items: [
                    BottomNavigationBarItem(
                      icon: _buildImageIcon(
                          3, "assets/me_icon.png", Colors.blueGrey, 20),
                      label: '我的',
                      activeIcon:
                          _buildImageIcon(3, "assets/me_icon.png", null, 20),
                    ),
                    BottomNavigationBarItem(
                      icon: _buildImageIcon(
                        0,
                        "assets/post_icon.png",
                        Colors.blueGrey,
                        30,
                      ),
                      label: '动态',
                      activeIcon: _buildImageIcon(
                        0,
                        "assets/post_icon.png",
                        null,
                        30,
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: _buildImageIcon(
                        3,
                        "assets/other_icon.png",
                        Colors.blueGrey,
                        20,
                      ),
                      label: '其它',
                      activeIcon: _buildImageIcon(
                        3,
                        "assets/other_icon.png",
                        null,
                        20,
                      ),
                    ),
                  ],
                ),
              ),
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

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('动态'));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('其它'));
  }
}


/*child: Scaffold(
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
              Stack(
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.mail_outline_rounded),
                      onPressed: () {
                        // setState(() {
                        //   newMessage = false;
                        // });
                        Navigator.pushNamed(context, '/chatListPage');
                      }),
                  newMessage
                      ? Positioned(
                          right: 12,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 6,
                              minHeight: 6,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              // IconButton(
              //   icon: const Icon(Icons.mail_outline_rounded),
              //   onPressed: () => Navigator.pushNamed(context, '/chatListPage'),
              // ),
              IconButton(
                icon: const Icon(Icons.menu),
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
      ),*/