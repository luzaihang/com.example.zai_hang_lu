import 'package:flutter/material.dart';
import 'package:ci_dong/factory_list/chat_detail_factory.dart';
import 'package:ci_dong/tencent/tencent_cloud_chatting_records_list.dart';
import 'package:ci_dong/widget_element/chat_list_item.dart';
import 'package:ci_dong/widget_element/preferredSize_item.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatDetailSender> chatList = [];

  @override
  void initState() {
    chattingRecordsList();
    super.initState();
  }

  Future<void> chattingRecordsList() async {
    chatList = await ChattingRecordsList.recordsList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: preferredSizeWidget(
        AppBar(
          title: const Text(
            '消息中心',
            style: TextStyle(fontSize: 15),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          automaticallyImplyLeading: false,
          // 不显示返回按钮
          leading: IconButton(
            icon: const ImageIcon(AssetImage("assets/back_icon.png")),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          ChatDetailSender item = chatList[index];
          return ChatListItem(
            senderAvatar: item.senderAvatar,
            senderName: item.senderName,
            senderID: item.senderID,
            message: item.message,
            time: item.time,
          );
        },
      ),
    );
  }
}
