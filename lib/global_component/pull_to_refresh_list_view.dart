import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RefreshListView extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadingMore;
  final List<Widget> children;
  final ScrollController controller;
  final bool isLoading;

  const RefreshListView({
    super.key,
    required this.onRefresh,
    required this.onLoadingMore,
    required this.children,
    required this.controller,
    required this.isLoading,
  });

  @override
  _RefreshListViewState createState() => _RefreshListViewState();
}

class _RefreshListViewState extends State<RefreshListView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() async {
      if (widget.isLoading) return;
      if (widget.controller.position.pixels ==
          widget.controller.position.maxScrollExtent) {
        await widget.onLoadingMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        itemCount: widget.children.length + (widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.children.length && widget.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: SpinKitCircle(
                  color: Colors.blue,
                ),
              ),
            );
          }
          return widget.children[index];
        },
        controller: widget.controller,
      ),
    );
  }
}
