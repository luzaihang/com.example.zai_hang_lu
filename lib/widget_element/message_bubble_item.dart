import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ci_dong/app_data/format_date_time.dart';
import 'package:ci_dong/app_data/user_info_config.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isMe) _buildAvatar(senderAvatar),
          const SizedBox(width: 10),
          Expanded(child: _buildMessageContent(context, timestamp)),
          const SizedBox(width: 10),
          if (isMe) _buildAvatar(UserInfoConfig.userAvatar),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    return avatarUrl.isNotEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 3),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(avatarUrl),
              radius: 20.0,
            ),
          )
        : Container(
            margin: const EdgeInsets.only(top: 3),
            child: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              radius: 20.0,
              child: Icon(Icons.person),
            ),
          );
  }

  Widget _buildMessageContent(BuildContext context, DateTime dateTime) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMe ? UserInfoConfig.userName : senderName,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(width: 8.0),
            Padding(
              padding: const EdgeInsets.only(top: 1.5),
              child: Text(
                formatDateTimeToMinutes(timestamp),
                style: const TextStyle(color: Colors.blueGrey, fontSize: 10.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          constraints: BoxConstraints(
            maxWidth: screenWidth - 130.0,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.green.withOpacity(0.8)
                : Colors.blueGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black.withOpacity(0.7),
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
