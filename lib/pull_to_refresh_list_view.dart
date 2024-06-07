import 'dart:async';

import 'package:flutter/material.dart';

class PullToRefreshListView extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final List<Widget> items;

  ///刷新、加载控件
  const PullToRefreshListView({
    super.key,
    required this.onRefresh,
    required this.onLoadMore,
    required this.items,
  });

  @override
  PullToRefreshListViewState createState() => PullToRefreshListViewState();
}

class PullToRefreshListViewState extends State<PullToRefreshListView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 30 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
    });
    await widget.onLoadMore();

    await Future.delayed(const Duration(milliseconds: 500)); // 延迟处理，模拟缓慢加载

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      backgroundColor: Colors.blueGrey,
      color: Colors.white,
      strokeWidth: 1.5,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.items.length) {
            return Center(
              child: Container(
                height: 30,
                alignment: Alignment.topCenter,
                child: const Text(
                  '正在加载...',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12.0,
                  ),
                ),
              ),
            );
          }
          return widget.items[index];
        },
      ),
    );
  }
}
