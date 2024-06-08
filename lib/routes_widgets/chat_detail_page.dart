import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/factory_list/chat_detail_factory.dart';

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

  void _handleSubmitted(String text) {
    _controller.clear();
    MessageBubble message = MessageBubble(
      text: text,
      isMe: true,
      timestamp: DateTime.now(), // 添加时间戳
    );

    ChatDetailSender chatDetailSender = ChatDetailSender(
      senderName: UserInfoConfig.userName,
      senderID: UserInfoConfig.userID,
      senderAvatar: UserInfoConfig.userAvatar,
      message: text,
      time: '',
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      MessageBubble(
          text: "Hello!",
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      MessageBubble(
          text: "Hi, how are you?",
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
      MessageBubble(
          text: "I'm fine, thanks!",
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Detail'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
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
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const MessageBubble({
    super.key,
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
            const CircleAvatar(child: Text('')),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Other',
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
                      Text('Me',
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
            const CircleAvatar(child: Text('Me')),
          ],
        ],
      ),
    );
  }
}
