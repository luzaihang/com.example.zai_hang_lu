import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    // final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: align,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isMe) _buildAvatar(senderAvatar),
          Expanded(child: _buildMessageContent(context, timestamp)),
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

  Widget _buildMessageContent(BuildContext context, DateTime dateTime) {
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
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.green.withOpacity(0.8)
                : Colors.blueGrey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(9.0),
          ),
          child: Text(
            text,
            style: TextStyle(color: isMe ? Colors.white : Colors.black.withOpacity(0.7)),
          ),
        ),
      ],
    );
  }
}
