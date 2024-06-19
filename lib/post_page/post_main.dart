import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ci_dong/post_page/all_post_list.dart';
import 'package:ci_dong/post_page/new_edit_post_page.dart';
import 'package:ci_dong/post_page/user_post_list.dart';
import 'package:ci_dong/provider/post_page_notifier.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';

class PostMain extends StatefulWidget {
  const PostMain({super.key});

  @override
  State<PostMain> createState() => _PostMainState();
}

class _PostMainState extends State<PostMain>
    with SingleTickerProviderStateMixin {
  // 自定义阈值，设定一个小于这个值的滑动速度被忽略
  final double swipeThreshold = 400;
  Alignment _alignment = Alignment.centerLeft;
  late VisibilityNotifier _visibilityNotifier;
  late PostPageNotifier _readNotifier;
  late PostPageNotifier _watchNotifier;

  @override
  void initState() {
    super.initState();
    _visibilityNotifier = context.read<VisibilityNotifier>();
    _readNotifier = context.read<PostPageNotifier>();
    _readNotifier.onRefresh(); //全部tab的数据
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchNotifier = context.watch<PostPageNotifier>();
  }

  void _onTabTapped(int index) {
    _readNotifier.indexPage(index);

    switch (index) {
      case 0:
        _alignment = Alignment.centerLeft;
        _visibilityNotifier.updateVisibility(true);
        break;
      case 1:
        _alignment = Alignment.center;
        _visibilityNotifier.updateVisibility(true);
        break;
      case 2:
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
        switch (_watchNotifier.selectedIndex) {
          case 0:
            _onTabTapped(1);
            break;
          case 1:
            _onTabTapped(2);
            break;
        }
      } else if (details.primaryVelocity! > 0) {
        // 右滑 去到左边的tab
        switch (_watchNotifier.selectedIndex) {
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
        child: Column(
          children: [
            SizedBox(height: 50, child: _buildTabBar()),
            Expanded(
              child: IndexedStack(
                index: _watchNotifier.selectedIndex,
                children: const [
                  AllPostListWidget(),
                  UserPostList(),
                  NewEditPost(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFF2F3F5),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTabItem(0, "全部"),
              _buildTabItem(1, "个人"),
              _buildTabItem(2, "发帖"),
            ],
          ),
          Positioned(
            bottom: 2,
            child: Container(
              width: 190,
              height: 3,
              padding: const EdgeInsets.only(left: 23, right: 3),
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
          _submitButton(),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return _watchNotifier.selectedIndex == 2 &&
            _watchNotifier.submitText.isNotEmpty
        ? Positioned(
            right: 12,
            bottom: 3,
            child: GestureDetector(
              onTap: () => _readNotifier.submitButton(),
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF052D84),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: const Text(
                  "发布",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildTabItem(int index, String text) {
    final bool isSelected = _watchNotifier.selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: 70,
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
                fontSize: isSelected ? 20 : 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
