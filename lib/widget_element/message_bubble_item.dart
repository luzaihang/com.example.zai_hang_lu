import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/widget_element/avatar_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:ci_dong/app_data/format_date_time.dart';
import 'package:ci_dong/app_data/user_info_config.dart';

class MessageBubble extends StatelessWidget {
  final String senderName;
  final String senderAvatar;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String senderID;

  const MessageBubble({
    super.key,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.senderID,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isMe) AvatarWidget(userId: senderID),
          const SizedBox(width: 10),
          Expanded(child: _buildMessageContent(context, timestamp)),
          const SizedBox(width: 10),
          if (isMe) AvatarWidget(userId: UserInfoConfig.uniqueID),
        ],
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
                color: Color(0xFF052D84),
              ),
            ),
            const SizedBox(width: 8.0),
            Padding(
              padding: const EdgeInsets.only(top: 1.5),
              child: Text(
                formatDateTimeToMinutes(timestamp),
                style: TextStyle(color: const Color(0xFF052D84).withOpacity(0.5), fontSize: 10.0),
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
              color: isMe ? Colors.white : const Color(0xFF052D84).withOpacity(0.8),
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
