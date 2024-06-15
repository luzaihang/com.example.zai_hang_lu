import 'package:ci_dong/factory_list/home_list_data.dart';
import 'package:ci_dong/post_page/all_post_list.dart';
import 'package:ci_dong/post_page/new_edit_post_page.dart';
import 'package:ci_dong/post_page/user_post_list.dart';
import 'package:ci_dong/provider/post_page_notifier.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/tencent/tencent_cloud_list_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class PostMain extends StatefulWidget {
  const PostMain({super.key});

  @override
  State<PostMain> createState() => _PostMainState();
}

class _PostMainState extends State<PostMain> {
  int _selectedIndex = 0;
  List<UserPost> directories = [];
  late ScrollController _scrollController;
  TencentCloudListData tencentCloudListData = TencentCloudListData();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final visibilityNotifier =
        Provider.of<VisibilityNotifier>(context, listen: false);

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      visibilityNotifier.updateVisibility(false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      visibilityNotifier.updateVisibility(true);
    }

    final postPageNotifier = Provider.of<PostPageNotifier>(context, listen: false);
    postPageNotifier.setIndexOff(_selectedIndex, _scrollController.offset);
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final postPageNotifier = Provider.of<PostPageNotifier>(context, listen: false);
    switch (_selectedIndex) {
      case 0:
        _scrollController.jumpTo(postPageNotifier.index0);
        break;
      case 1:
        _scrollController.jumpTo(postPageNotifier.index1);
        break;
      case 2:
        _scrollController.jumpTo(postPageNotifier.index2);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Padding(
      // CustomScrollView默认是可以划入状态栏的，所以保持与其他页面一致可以这么做 EdgeInsets.only(top: statusBarHeight)
      padding: EdgeInsets.only(top: statusBarHeight),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          const SliverPadding(
            padding: EdgeInsets.only(top: 45),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Padding(
                  padding: EdgeInsets.only(left: 24),
                  // alignment: Alignment.centerLeft,
                  child: Text(
                    "动态中心",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF000822),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: _SliverAppBarDelegate(
              minHeight: 40,
              maxHeight: 40,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 0,
                ),
                color: const Color(0xFFF2F3F5),
                // color: Colors.blueGrey,
                child: Row(
                  children: [
                    _buildTabItem(0, "全部"),
                    _buildTabItem(1, "个人"),
                    _buildTabItem(2, "发帖"),
                  ],
                ),
              ),
            ),
          ),
          _getSelectedContent(),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String text) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        margin: const EdgeInsets.only(
          right: 40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF052D84)
                    : const Color(0xFF052D84).withOpacity(0.5),
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                height: 3,
                width: 40, // 根据需要调整宽度
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: const Color(0xFF052D84),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return const AllPostListWidget();
      case 1:
        return const UserPostList();
      case 2:
        return const NewEditPost();
      default:
        return const Text("未知内容");
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
