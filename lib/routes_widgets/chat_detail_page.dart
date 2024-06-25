import 'dart:async';
import 'package:ci_dong/provider/chat_notifier.dart';
import 'package:flutter/material.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/chat_detail_from_map.dart';
import 'package:ci_dong/tencent/tencent_cloud_download.dart';
import 'package:ci_dong/tencent/tencent_cloud_upload.dart';
import 'package:ci_dong/widget_element/message_bubble_item.dart';
import 'package:provider/provider.dart';

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

  late ChatNotifier _chatReadNotifier;
  final FocusNode _focusNode = FocusNode();

  List<ChatDetailFromMap> newMessages = []; // 新增列表用于保存新消息

  @override
  void initState() {
    super.initState();
    _chatReadNotifier = context.read<ChatNotifier>();
    _chatReadNotifier.messageText = ""; //进入页面时重定为空，避免其他人的聊天介入
    _chatReadNotifier.isDetail = true; //消息监听设置为聊天详情
    _loadChattingRecords(); // 加载聊天记录
    //().d("----------${_chatReadNotifier.isDetail}");
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final chatWatchNotifier = context.watch<ChatNotifier>();
    //().i(chatWatchNotifier.messageText);
    if (mounted && chatWatchNotifier.messageText.isNotEmpty) {
      await _addMessage(
        senderName: widget.taUserName,
        senderAvatar: widget.taUserAvatar,
        text: chatWatchNotifier.messageText,
        isMe: false,
        timestamp: DateTime.now(),
        senderID: widget.taUserID,
      ).then((value) {
        //接收到消息时，上传数据到云端
        _uploadChatDetails();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _chatReadNotifier.isDetail = false; //取消聊天详情监听
    //().d("----------${_chatReadNotifier.isDetail}");
    super.dispose();
  }

  Future<void> _loadChattingRecords() async {
    List<ChatDetailFromMap> list = await chattingRecords();
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
            senderID: detail.senderID,
          );
        } catch (e, stackTrace) {
        }
      }
    } else {
    }
  }

  Future<List<ChatDetailFromMap>> chattingRecords() async {
    var chatDetails = await TencentCloudTxtDownload.chatTxt(widget.taUserID);
    return chatDetails;
  }

  Future<void> _addMessage({
    required String senderName,
    required String senderAvatar,
    required String text,
    required bool isMe,
    required DateTime timestamp,
    required String senderID,
  }) async {
    MessageBubble messageBubble = MessageBubble(
      senderName: senderName,
      senderAvatar: senderAvatar,
      text: text,
      isMe: isMe,
      timestamp: timestamp,
      senderID: senderID,
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
          ChatDetailFromMap(
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

    chatUpload(widget.taUserID, listMap);

    //().i("上传聊天记录到云端: ${newMessages.length} 条消息");
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    Conversation conversation =
        await _chatReadNotifier.client.createConversation(
      members: {widget.taUserID},
    );

    TextMessage textMessage = TextMessage.from(text: text);
    await conversation.send(message: textMessage);
    //发送消息时，上传数据到云端
    _uploadChatDetails();
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
      senderID: UserInfoConfig.uniqueID,
    );
    sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF2F3F5),
        body: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                left: 20,
                top: 45,
                bottom: 5,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/back_icon.png",
                      width: 18,
                      height: 18,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.taUserName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildTextComposer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              focusNode: _focusNode,
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
