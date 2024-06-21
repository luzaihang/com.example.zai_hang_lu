import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String userId;

  ///获取头像
  const AvatarWidget({super.key, required this.userId});

  Future<String> avatarUrl(String userid) async {
    try {
      String url =
          "${DefaultConfig.avatarAndPostPrefix}/$userid/userAvatar.png";
      bool res = await checkUrlExists(url);
      if (!res) {
        return "";
      }
      return url;
    } catch (e) {
      return "";
    }
  }

  Future<bool> checkUrlExists(String urlString) async {
    final url = Uri.parse(urlString);
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(milliseconds: 1000);

    try {
      final request = await httpClient.headUrl(url);
      request.followRedirects = false;
      final response = await request.close();
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      return false;
    } finally {
      httpClient.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        height: 40,
        width: 40,
        color: const Color(0xFF052D84),
        child: FutureBuilder<String>(
          future: avatarUrl(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(color: const Color(0xFF052D84)); // 加载中的占位符
            } else if (snapshot.hasError) {
              return const Icon(Icons.error, color: Colors.white); // 错误时展示的占位符
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Icon(Icons.person,
                  color: Colors.white); // 链接不存在时展示的占位符
            } else {
              return CachedNetworkImage(
                imageUrl: snapshot.data!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: const Color(0xFF052D84)),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.white,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}