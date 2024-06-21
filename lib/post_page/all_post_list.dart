import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/global_component/pull_to_refresh_list_view.dart';
import 'package:ci_dong/provider/post_page_notifier.dart';
import 'package:ci_dong/provider/upvote_notifier.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/widget_element/post_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllPostListWidget extends StatefulWidget {
  const AllPostListWidget({super.key});

  @override
  State<AllPostListWidget> createState() => _AllPostListWidgetState();
}

class _AllPostListWidgetState extends State<AllPostListWidget> {
  late ScrollController _scrollController;
  late VisibilityNotifier _visibilityNotifier;
  late PostPageNotifier _watchNotifier;
  late PostPageNotifier _readNotifier;

  @override
  void initState() {
    super.initState();
    _readNotifier = context.read<PostPageNotifier>();
    _visibilityNotifier = context.read<VisibilityNotifier>();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _readNotifier.onAllRefresh();
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

    return Consumer<PostPageNotifier>(builder:
        (BuildContext context, PostPageNotifier provider, Widget? child) {
      return SmartRefresher(
        controller: provider.allRefreshController,
        onRefresh: () => provider.onAllRefresh(),
        onLoading: () => provider.onAllLoadMore(),
        header: headerRefresh(),
        footer: footerLoad(),
        enablePullUp: true,
        child: provider.allTabList.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                itemCount: provider.allTabList.length,
                itemBuilder: (BuildContext context, int index) {
                  PostDetailFormJson item = provider.allTabList[index];
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
