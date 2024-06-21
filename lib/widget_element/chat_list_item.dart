import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/widget_element/avatar_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:ci_dong/app_data/format_date_time.dart';
import 'package:ci_dong/global_component/route_generator.dart';

class ChatListItem extends StatelessWidget {
  final String senderAvatar;
  final String senderName;
  final String senderID;
  final String message;
  final String time;

  const ChatListItem({
    Key? key,
    required this.senderAvatar,
    required this.senderName,
    required this.senderID,
    required this.message,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToChatDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: <Widget>[
            AvatarWidget(userId: senderID),
            const SizedBox(width: 10.0),
            Expanded(
              child: _buildChatContent(),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChatDetail(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/chatDetailPage',
      arguments: ChatDetailPageArguments(
        taUserName: senderName,
        taUserID: senderID,
        taUserAvatar: senderAvatar,
      ),
    );
  }

  Widget _buildChatContent() {
    DateTime getTime = DateTime.parse(time);
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.3,
            color: Colors.blueGrey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSenderInfo(),
          const SizedBox(width: 10.0),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              formatDateTimeToMinutes(getTime),
              style: TextStyle(
                color: const Color(0xFF052D84).withOpacity(0.5),
                fontSize: 11.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          senderName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.0,
            color: Color(0xFF052D84),
          ),
        ),
        Text(
          message,
          style: TextStyle(
            color: const Color(0xFF052D84).withOpacity(0.5),
            fontSize: 12.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
