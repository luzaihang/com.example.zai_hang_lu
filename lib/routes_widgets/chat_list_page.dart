import 'package:flutter/material.dart';
import 'package:zai_hang_lu/factory_list/chat_detail_factory.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_chatting_records_list.dart';
import 'package:zai_hang_lu/widget_element/chat_list_item.dart';

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
      appBar: AppBar(
        title: const Text('chat'),
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
