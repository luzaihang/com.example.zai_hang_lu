import 'package:cached_network_image/cached_network_image.dart';
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
            _buildSenderAvatar(),
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

  Widget _buildSenderAvatar() {
    return senderAvatar.isNotEmpty
        ? CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(senderAvatar),
            radius: 20.0,
          )
        : const CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: 20.0,
            child: Icon(Icons.person),
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
              style: const TextStyle(color: Colors.grey, fontSize: 11.0),
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
            color: Colors.blueGrey,
          ),
        ),
        Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 12.0),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
