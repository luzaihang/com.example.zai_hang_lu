import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/factory_list/chat_detail_factory.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_txt_download.dart';

import '../tencent/tencent_upload_download.dart';

class ChatDetailPage extends StatefulWidget {
  final String taUserName;
  final String taUserAvatar;
  final String taUserID;

  ///聊天页面(聊天详情页)
  const ChatDetailPage({
    super.key,
    required this.taUserName,
    required this.taUserAvatar,
    required this.taUserID,
  });

  @override
  ChatDetailPageState createState() => ChatDetailPageState();
}

class ChatDetailPageState extends State<ChatDetailPage> {
  final List<MessageBubble> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ChatDetailSender> chatDetailsList = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadChatList();
    _startPeriodicRequest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startPeriodicRequest() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      _loadChatList();
    });
  }

  Future<void> _loadChatList() async {
    try {
      var chatDetails = await TencentCloudTxtDownload.chatTxt(widget.taUserID);
      setState(() {
        chatDetailsList = chatDetails;
        _messages.clear();
        for (var chatDetail in chatDetailsList) {
          bool isMe = chatDetail.senderID == UserInfoConfig.userID;
          DateTime timestamp = DateTime.parse(chatDetail.time);

          MessageBubble message = MessageBubble(
            senderName: isMe ? UserInfoConfig.userName : chatDetail.senderName,
            senderAvatar:
                isMe ? UserInfoConfig.userAvatar : chatDetail.senderAvatar,
            text: chatDetail.message,
            isMe: isMe,
            timestamp: timestamp,
          );

          _messages.insert(0, message);
        }
      });
    } catch (e) {
      // 这里可以增加错误处理逻辑，例如展示错误信息
      Logger().e('Error loading chat list: $e');
    }
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    _controller.clear();
    DateTime now = DateTime.now();

    // 创建新的消息气泡和消息对象
    MessageBubble message = MessageBubble(
      senderName: UserInfoConfig.userName,
      senderAvatar: UserInfoConfig.userAvatar,
      text: text,
      isMe: true,
      timestamp: now,
    );

    ChatDetailSender chatDetailSender = ChatDetailSender(
      senderName: UserInfoConfig.userName,
      senderID: UserInfoConfig.userID,
      senderAvatar: UserInfoConfig.userAvatar,
      message: text,
      time: now.toIso8601String(),
    );

    // 更新本地状态和上传消息
    setState(() {
      _messages.insert(0, message);
      chatDetailsList.add(chatDetailSender);
    });

    _uploadChatList();
  }

  void _uploadChatList() {
    List<Map<String, dynamic>> messagesList =
        chatDetailsList.map((chatDetail) => chatDetail.toMap()).toList();
    TencentUpLoadAndDownload.chatUpload(widget.taUserID, messagesList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.taUserName),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const ImageIcon(AssetImage("assets/back_icon.png")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Row(
      children: <Widget>[
        Flexible(
          child: TextField(
            controller: _controller,
            onSubmitted: _handleSubmitted,
            decoration: const InputDecoration.collapsed(
              hintText: '请输入',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.send,
            color: Colors.blue,
          ),
          onPressed: () => _handleSubmitted(_controller.text),
        ),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String senderName;
  final String senderAvatar;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const MessageBubble({
    super.key,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        isMe ? Colors.green.withOpacity(0.8) : Colors.blueGrey.withOpacity(0.2);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final timeFormat = DateFormat('h:mm a'); // 设置时间格式

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: align,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isMe) ...[
            senderAvatar.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(senderAvatar),
                    radius: 22.0,
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    radius: 22.0,
                    child: Icon(Icons.person),
                  ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(senderName,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 8.0), // 添加一些间距
                      Text(
                        timeFormat.format(timestamp), // 显示时间戳
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isMe) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeFormat.format(timestamp), // 显示时间戳
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 10.0,
                        ),
                      ),
                      const SizedBox(width: 8.0), // 添加一些间距
                      Text(UserInfoConfig.userName,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            UserInfoConfig.userAvatar.isNotEmpty
                ? CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(UserInfoConfig.userAvatar),
                    radius: 22.0,
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    radius: 22.0,
                    child: Icon(Icons.person),
                  ),
          ],
        ],
      ),
    );
  }
}
