import 'package:flutter/material.dart';

///中间弹窗
void showCustomDialog(BuildContext context, String content) {
  showDialog(
    context: context,
    barrierDismissible: false, // 禁止点击外部关闭弹窗
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return _CustomDialog(content: content);
    },
  );
}

class _CustomDialog extends StatefulWidget {
  final String content;

  const _CustomDialog({required this.content});

  @override
  __CustomDialogState createState() => __CustomDialogState();
}

class __CustomDialogState extends State<_CustomDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    _animationController.forward();

    // 3秒后自动开始反向动画，之后关闭弹窗
    Future.delayed(const Duration(seconds: 2), () {
      _animationController
          .reverse()
          .then((value) => Navigator.of(context).pop());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.content,
              style: const TextStyle(
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
