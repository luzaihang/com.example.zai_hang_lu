import 'dart:async';
import 'package:ci_dong/lean_cloud/client_manager.dart';
import 'package:flutter/material.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:logger/logger.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/chat_detail_factory.dart';
import 'package:ci_dong/tencent/tencent_cloud_txt_download.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';
import 'package:ci_dong/widget_element/message_bubble_item.dart';
import 'package:ci_dong/widget_element/preferredSize_item.dart';

class ChatDetailPage extends StatefulWidget {
  final String taUserName;
  final String taUserAvatar;
  final String taUserID;

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

  Client client = ClientManager().client;

  List<ChatDetailSender> newMessages = []; // 新增列表用于保存新消息

  @override
  void initState() {
    super.initState();
    _setupClientMessageListener();
    _loadChattingRecords(); // 加载聊天记录
  }

  @override
  void dispose() {
    _controller.dispose();
    _uploadChatDetails(); // 页面退出时合并并上传聊天记录
    super.dispose();
  }

  Future<void> _loadChattingRecords() async {
    List<ChatDetailSender> list = await chattingRecords();
    if (list.isNotEmpty) {
      for (var detail in list) {
        // 确保消息按顺序加载，避免冲突或覆盖
        try {
          await _addMessage(
            senderName: detail.senderName,
            senderAvatar: detail.senderAvatar,
            text: detail.message,
            isMe: detail.senderID == UserInfoConfig.uniqueID,
            timestamp: DateTime.parse(detail.time),
          );
        } catch (e, stackTrace) {
          Logger().e("Error adding message: ${detail.message}",
              stackTrace: stackTrace);
        }
      }
    } else {
      Logger().w("list is empty after loading.");
    }
  }

  Future<List<ChatDetailSender>> chattingRecords() async {
    var chatDetails = await TencentCloudTxtDownload.chatTxt(widget.taUserID);
    return chatDetails;
  }

  void _setupClientMessageListener() {
    client.onMessage = ({
      required Client client,
      required Conversation conversation,
      required Message message,
    }) async {
      String? text = message is TextMessage ? message.text : '消息内容为空';
      await _addMessage(
        senderName: widget.taUserName,
        senderAvatar: widget.taUserAvatar,
        text: text ?? "",
        isMe: false,
        timestamp: DateTime.now(),
      );
    };
  }

  Future<void> _addMessage({
    required String senderName,
    required String senderAvatar,
    required String text,
    required bool isMe,
    required DateTime timestamp,
  }) async {
    MessageBubble messageBubble = MessageBubble(
      senderName: senderName,
      senderAvatar: senderAvatar,
      text: text,
      isMe: isMe,
      timestamp: timestamp,
    );
    setState(() {
      _messages.insert(0, messageBubble);
      // 增加新信息的详细日志，检查条件判断
      bool messageExists = newMessages.any((item) =>
          item.senderName == senderName &&
          item.senderID == (isMe ? UserInfoConfig.uniqueID : widget.taUserID) &&
          item.senderAvatar == senderAvatar &&
          item.message == text &&
          item.time == timestamp.toIso8601String());

      if (!messageExists) {
        newMessages.add(
          ChatDetailSender(
            senderName: senderName,
            senderID: isMe ? UserInfoConfig.uniqueID : widget.taUserID,
            senderAvatar: senderAvatar,
            message: text,
            time: timestamp.toIso8601String(),
          ),
        );
      }
    });
  }

  Future<void> _uploadChatDetails() async {
    List<Map<String, dynamic>> listMap =
        newMessages.map((detail) => detail.toMap()).toList();

    TencentUpLoadAndDownload.chatUpload(widget.taUserID, listMap);

    Logger().i("上传聊天记录到云端: ${newMessages.length} 条消息");
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    Conversation conversation = await client.createConversation(
      members: {widget.taUserID},
    );

    TextMessage textMessage = TextMessage.from(text: text);
    await conversation.send(message: textMessage);
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;
    _controller.clear();
    await _addMessage(
      senderName: UserInfoConfig.userName,
      senderAvatar: UserInfoConfig.userAvatar,
      text: text,
      isMe: true,
      timestamp: DateTime.now(),
    );
    sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
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
      ),
    );
  }

  PreferredSize _buildAppBar() {
    return preferredSizeWidget(
      AppBar(
        title: Text(
          widget.taUserName,
          style: const TextStyle(fontSize: 15),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const ImageIcon(AssetImage("assets/back_icon.png")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                // 移除边框
                isDense: true,
                // 减少内边距
                contentPadding: EdgeInsets.zero,
                // 设置内边距为0
                counterText: "",
                hintText: "最多可输入520字",
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              cursorColor: Colors.blueGrey,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(5),
              style: const TextStyle(color: Colors.blueGrey),
              maxLength: 520,
              controller: _controller,
              onSubmitted: _handleSubmitted,
              maxLines: 5,
              minLines: 1,
            ),
          ),
          GestureDetector(
            onTap: () => _handleSubmitted(_controller.text),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Text(
                "发送",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
