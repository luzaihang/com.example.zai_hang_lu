import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:logger/logger.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';

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

  late Client client;

  @override
  void initState() {
    super.initState();
    _initializeLeanCloud();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeLeanCloud() async {
    client = Client(id: UserInfoConfig.userID);
    await client.open();
    _setupClientMessageListener();
  }

  void _setupClientMessageListener() {
    client.onMessage = ({
      required Client client,
      required Conversation conversation,
      required Message message,
    }) {
      String? text = message is TextMessage ? message.text : '消息内容为空';
      _addMessage(
        senderName: widget.taUserName,
        senderAvatar: widget.taUserAvatar,
        text: text ?? "",
        isMe: false,
      );
      Logger().d(message);
    };
  }

  void _addMessage({
    required String senderName,
    required String senderAvatar,
    required String text,
    required bool isMe,
  }) {
    DateTime now = DateTime.now();
    MessageBubble messageBubble = MessageBubble(
      senderName: senderName,
      senderAvatar: senderAvatar,
      text: text,
      isMe: isMe,
      timestamp: now,
    );

    setState(() {
      _messages.insert(0, messageBubble);
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    Conversation conversation = await client.createConversation(
      members: {widget.taUserID},
    );

    TextMessage textMessage = TextMessage.from(text: text);
    await conversation.send(message: textMessage);
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    _controller.clear();
    _addMessage(
      senderName: UserInfoConfig.userName,
      senderAvatar: UserInfoConfig.userAvatar,
      text: text,
      isMe: true,
    );
    sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.taUserName),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,
      leading: IconButton(
        icon: const ImageIcon(AssetImage("assets/back_icon.png")),
        onPressed: () {
          Navigator.pop(context);
        },
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
            decoration: const InputDecoration.collapsed(hintText: '请输入'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.blue),
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
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: align,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isMe) _buildAvatar(senderAvatar),
          Expanded(child: _buildMessageContent(context, timeFormat)),
          if (isMe) _buildAvatar(UserInfoConfig.userAvatar),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    return avatarUrl.isNotEmpty
        ? CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
            radius: 22.0,
          )
        : const CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: 22.0,
            child: Icon(Icons.person),
          );
  }

  Widget _buildMessageContent(BuildContext context, DateFormat timeFormat) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMe ? UserInfoConfig.userName : senderName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8.0),
            Text(
              timeFormat.format(timestamp),
              style: const TextStyle(color: Colors.blueGrey, fontSize: 10.0),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.green.withOpacity(0.8)
                : Colors.blueGrey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            text,
            style: TextStyle(color: isMe ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
