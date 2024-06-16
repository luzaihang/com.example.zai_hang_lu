import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:ci_dong/post_page/all_post_list.dart';
import 'package:ci_dong/post_page/new_edit_post_page.dart';
import 'package:ci_dong/post_page/user_post_list.dart';
import 'package:ci_dong/provider/post_page_notifier.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/tencent/tencent_cloud_list_data.dart';

class PostMain extends StatefulWidget {
  const PostMain({super.key});

  @override
  State<PostMain> createState() => _PostMainState();
}

class _PostMainState extends State<PostMain>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // 自定义阈值，设定一个小于这个值的滑动速度被忽略
  final double swipeThreshold = 400;
  Alignment _alignment = Alignment.centerLeft;
  late VisibilityNotifier _visibilityNotifier;
  late PostPageNotifier _postPageNotifier;

  late ScrollController _scrollController;
  final TencentCloudListData tencentCloudListData = TencentCloudListData();

  @override
  void initState() {
    super.initState();
    _visibilityNotifier = context.read<VisibilityNotifier>();
    _postPageNotifier = context.read<PostPageNotifier>();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postPageNotifier.removeListener(() {});
    super.dispose();
  }

  void _scrollListener() {
    //如果是 发帖页面，不操作底部切换栏的展示以及消失
    if (_selectedIndex == 2) return;

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      _visibilityNotifier.updateVisibility(false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      _visibilityNotifier.updateVisibility(true);
    }

    _postPageNotifier.setIndexOffset(_selectedIndex, _scrollController.offset);
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
        _scrollController.jumpTo(_postPageNotifier.index0);
        _alignment = Alignment.centerLeft;
        _visibilityNotifier.updateVisibility(true);
        break;
      case 1:
        _scrollController.jumpTo(_postPageNotifier.index1);
        _alignment = Alignment.center;
        _visibilityNotifier.updateVisibility(true);
        break;
      case 2:
        _scrollController.jumpTo(_postPageNotifier.index2);
        _alignment = Alignment.centerRight;
        _visibilityNotifier.updateVisibility(false);
        break;
    }
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    // 检查水平方向滑动
    if (details.primaryVelocity!.abs() > swipeThreshold) {
      if (details.primaryVelocity! < 0) {
        // 左滑 去到右边的tab
        switch (_selectedIndex) {
          case 0:
            _onTabTapped(1);
            break;
          case 1:
            _onTabTapped(2);
            break;
        }
      } else if (details.primaryVelocity! > 0) {
        // 右滑 去到左边的tab
        switch (_selectedIndex) {
          case 2:
            _onTabTapped(1);
            break;
          case 1:
            _onTabTapped(0);
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight),
      child: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 50,
                maxHeight: 50,
                child: _buildTabBar(),
              ),
            ),
            _getSelectedContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFF2F3F5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabItem(0, "全部"),
              _buildTabItem(1, "个人"),
              _buildTabItem(2, "发帖"),
            ],
          ),
          Positioned(
            bottom: 2,
            child: SizedBox(
              width: 115,
              height: 3,
              child: AnimatedAlign(
                alignment: _alignment,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  height: 3,
                  width: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: const Color(0xFF052D84),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String text) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: 45,
        alignment: Alignment.center,
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
            const SizedBox(height: 6),
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

// double screenWidth = MediaQuery.of(context).size.width;

/*
SliverList(
  delegate: SliverChildListDelegate(
    [
      const Padding(
        padding: EdgeInsets.only(left: 24),
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
),*/
