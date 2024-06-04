import 'package:flutter/material.dart';

class PullToRefreshListView extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefreshListView({
    Key? key,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  PullToRefreshListViewState createState() => PullToRefreshListViewState();
}

// 注意：确保_state类也是公开的
class PullToRefreshListViewState extends State<PullToRefreshListView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.child,
    );
  }
}
