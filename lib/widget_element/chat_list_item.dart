import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String message;
  final String time;

  ///聊天列表项
  const ChatListItem({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          avatarUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(avatarUrl),
                  radius: 22.0,
                )
              : const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  radius: 22.0,
                  child: Icon(Icons.person),
                ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.blueGrey,
                        ),
                      ),
                      // const SizedBox(height: 4.0),
                      Text(
                        message,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10.0),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      time,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 11.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
