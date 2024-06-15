import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/factory_list/home_list_data.dart';
import 'package:ci_dong/post_page/new_edit_post_page.dart';
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
    _onRefresh();
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
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          /*
          ),*/
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
    return const ImagePickerWidget();
    // return AllPostListWidget();
    /*switch (_selectedIndex) {
      case 0:
        return const AllPostListWidget();
      case 1:
        return const Text("个人内容");
      case 2:
        return const Text("发帖内容");
      default:
        return const Text("未知内容");
    }*/
  }
}

class AllPostListWidget extends StatelessWidget {
  const AllPostListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // int index = 0; //这里还没有设置
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, index == 0 ? 20 : 0, 20, 0),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/chat_icon.png",
                      height: 36,
                      width: 36,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '缘聚缘散缘如水',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF052D84),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            '累计获赞: 10000次',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF052D84).withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        "assets/like_icon.png",
                        height: 28,
                        width: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(65, 10, 20, 0),
                child: Text(
                  '刚发现我车上被贴了这种东西贴在不显眼的位置好像是某种符有人知道这是啥吗?',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: Color(0xFF052D84),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(65, 10, 0, 0),
                child: Row(
                  children: [
                    Stack(
                      // alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            width: screenWidth * (2 / 3),
                            imageUrl:
                                'https://user-info-1322814250.cos.ap-shanghai.myqcloud.com/241718341476_.pic.jpg',
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/image_more_icon.png",
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "X6",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(65, 10, 10, 20),
                child: Row(
                  children: [
                    Container(
                      width: screenWidth * (2 / 3),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '点击可直接和TA取得联系~',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: const Color(0xFF052D84).withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        childCount: 5,
      ),
    );
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
