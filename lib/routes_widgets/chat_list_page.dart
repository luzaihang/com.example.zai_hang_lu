import 'package:flutter/material.dart';
import 'package:ci_dong/factory_list/chat_detail_from_map.dart';
import 'package:ci_dong/tencent/tencent_cloud_chatting_records_list.dart';
import 'package:ci_dong/widget_element/chat_list_item.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatDetailFromMap> chatList = [];

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
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: 20,
              top: 45,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/back_icon.png",
                    width: 24,
                    height: 24,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                // const SizedBox(width: 10),
                const Text(
                  "消息中心",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                ChatDetailFromMap item = chatList[index];
                return ChatListItem(
                  senderAvatar: item.senderAvatar,
                  senderName: item.senderName,
                  senderID: item.senderID,
                  message: item.message,
                  time: item.time,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
