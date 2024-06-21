import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/global_component/pull_to_refresh_list_view.dart';
import 'package:ci_dong/provider/post_page_notifier.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/tencent/tencent_cloud_list_data.dart';
import 'package:ci_dong/widget_element/post_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserPostList extends StatefulWidget {
  const UserPostList({super.key});

  @override
  State<UserPostList> createState() => _UserPostListState();
}

class _UserPostListState extends State<UserPostList> {
  TencentCloudListData tencentCloudListData = TencentCloudListData();
  late ScrollController _scrollController;
  late VisibilityNotifier _visibilityNotifier;
  late PostPageNotifier _watchNotifier;
  late PostPageNotifier _readNotifier;

  @override
  void initState() {
    super.initState();
    _visibilityNotifier = context.read<VisibilityNotifier>();
    _readNotifier = context.read<PostPageNotifier>();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _readNotifier.onUserRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchNotifier = context.watch<PostPageNotifier>();
  }

  void _scrollListener() {
    //如果是 发帖页面，不操作底部切换栏的展示以及消失
    if (_watchNotifier.selectedIndex == 2) return;
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      _visibilityNotifier.updateVisibility(false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      _visibilityNotifier.updateVisibility(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<PostPageNotifier>(
        builder: (BuildContext context, provider, Widget? child) {
      return SmartRefresher(
        controller: provider.userRefreshController,
        onRefresh: () => provider.onUserRefresh(),
        header: headerRefresh(),
        child: provider.userTabList.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                itemCount: provider.userTabList.length,
                itemBuilder: (BuildContext context, int index) {
                  PostDetailFormJson item = provider.userTabList[index];
                  return PostListItem(
                    item: item,
                    screenWidth: screenWidth,
                    index: index,
                  );
                },
              )
            : Center(
                child: Image.asset(
                  "assets/not_post_icon.png",
                  width: 80,
                  height: 80,
                  color: const Color(0xFF052D84),
                ),
              ),
      );
    });
  }
}
