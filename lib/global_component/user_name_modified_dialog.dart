import 'package:flutter/material.dart';

class ModifiedNameDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  ModifiedNameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 10.0, // 设置对话框的阴影高度
      shadowColor: Colors.blue.withOpacity(0.2), // 设置对话框阴影的颜色
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: InputBorder.none, // 移除边框
              isDense: true, // 减少内边距
              contentPadding: EdgeInsets.zero, // 设置内边距为0
              hintText: '请输入新昵称',
              hintStyle: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey,
              )
            ),
          ),
          const Divider(
            color: Colors.blueGrey, // 分割线颜色
            thickness: 0.1, // 分割线厚度
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, null);
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
                  Navigator.pop(context, _controller.text);
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
    );
  }
}
