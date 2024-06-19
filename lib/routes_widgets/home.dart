import 'package:ci_dong/lean_cloud/client_manager.dart';
import 'package:ci_dong/my_page/my_main.dart';
import 'package:ci_dong/post_page/post_main.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/setting_page/setting_main.dart';
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
  /// 文件列表
  List<UserPost> directories = [];
  TencentCloudListData tencentCloudListData = TencentCloudListData();

  bool newMessage = false;
  bool _isActive = true;
  late VisibilityNotifier _visibilityNotifier;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _initializeResources();
    _initializeAnimations();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(_initializeVisibilityNotifier);
  }

  void _initializeResources() {
    _onRefresh();
    _leanCloudInit();
  }

  void _initializeAnimations() {
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
  }

  void _initializeVisibilityNotifier(_) {
    _visibilityNotifier = context.read<VisibilityNotifier>();
    _visibilityNotifier.addListener(_toggleBottomNavigationBar);
    _visibilityNotifier.updateVisibility(true);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _visibilityNotifier.removeListener(_toggleBottomNavigationBar);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isActive = state == AppLifecycleState.resumed;
  }

  void _toggleBottomNavigationBar() {
    _visibilityNotifier.isVisible
        ? _controller.forward()
        : _controller.reverse();
  }

  Future<void> _leanCloudInit() async {
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
    directories = await tencentCloudListData.getAllFirstContentsList() ?? [];
    setState(() {});
  }

  Future<void> _onLoadMore() async {
    List<UserPost>? result = await tencentCloudListData.getAllNextContentsList();
    if (result != null) {
      directories.addAll(result);
      setState(() {});
    }
  }

  int _currentIndex = 0;
  final List<Widget> _children = [
    const MyMain(),
    const PostMain(),
    const SettingPageMain(),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitConfirmationDialog(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F3F5),
        body: Stack(
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
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12.0,
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
                          0, "assets/post_icon.png", Colors.blueGrey, 30),
                      label: '动态',
                      activeIcon:
                          _buildImageIcon(0, "assets/post_icon.png", null, 30),
                    ),
                    BottomNavigationBarItem(
                      icon: _buildImageIcon(
                          3, "assets/other_icon.png", Colors.blueGrey, 20),
                      label: '设置',
                      activeIcon:
                          _buildImageIcon(3, "assets/other_icon.png", null, 20),
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
