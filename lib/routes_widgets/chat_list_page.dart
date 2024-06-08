import 'package:flutter/material.dart';
import 'package:zai_hang_lu/widget_element/chat_list_item.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chat'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false, // 不显示返回按钮
        leading: IconButton(
          icon: const ImageIcon(AssetImage("assets/back_icon.png")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: const <Widget>[
          ChatListItem(
            avatarUrl: '',
            name: 'Soul空间站',
            message: '一个人吃饭也是件幸福的事',
            time: '12:00',
          ),
          ChatListItem(
            avatarUrl: '',
            name: 'Soul空间站',
            message: '一个人吃饭也是件幸福的事',
            time: '12:00',
          ),
        ],
      ),
    );
  }
}
