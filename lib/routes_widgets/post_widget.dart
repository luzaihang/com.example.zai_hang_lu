import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String username;
  final String postTime;
  final String location;
  final String message;
  final List<String> images;

  const PostWidget({super.key,
    required this.username,
    required this.postTime,
    required this.location,
    required this.message,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    // 只取前两张图
    List<String> displayImages = images.length > 2 ? images.sublist(0, 2) : images;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/directories_icon.png'), // 头像图片
                radius: 24.0,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Text(
                          postTime,
                          style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          location,
                          style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: List.generate(2, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 0 ? 8.0 : 0.0), // 图片间距
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: displayImages.length > index
                        ? Image.asset(
                      displayImages[index],
                      fit: BoxFit.cover,
                    )
                        : Container(), // 防止数组越界
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}