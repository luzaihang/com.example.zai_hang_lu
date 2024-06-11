import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String dynamicText;

  const CustomDialog({
    super.key,
    required this.dynamicText,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 禁用返回键关闭对话框
      child: AlertDialog(
        elevation: 10.0, // 设置对话框的阴影高度
        shadowColor: Colors.blue.withOpacity(0.2), // 设置对话框阴影的颜色
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              dynamicText,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.blueGrey,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(
                color: Colors.blueGrey, // 分割线颜色
                thickness: 0.1, // 分割线厚度
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, false); // 返回false
                  },
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, true); // 返回true
                  },
                  child: Text(
                    '下一步',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showCustomDialog(BuildContext context, String dynamicText) {
  return showDialog<bool?>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.2),
    barrierDismissible: false, // 设置为false，点击对话框外部不关闭
    builder: (BuildContext context) {
      return CustomDialog(dynamicText: dynamicText);
    },
  );
}
