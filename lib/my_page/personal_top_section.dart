import 'dart:ui';

import 'package:ci_dong/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/provider/personal_name_notifier.dart';

class PersonalTopSection extends StatelessWidget {
  final String userId;
  final String avatarUrl;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onChatButtonPressed;

  const PersonalTopSection({
    super.key,
    required this.userId,
    required this.avatarUrl,
    required this.onBackButtonPressed,
    required this.onChatButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    appLogger.d(userId);
    appLogger.d(avatarUrl);
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            "$avatarUrl?${DateTime.now().millisecondsSinceEpoch}",
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          child: _buildAvatarAndInfo(context),
        ),
        Positioned(
          top: 45,
          right: 20,
          child: GestureDetector(
            onTap: onBackButtonPressed,
            child: const Text(
              "返回",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        userId != UserInfoConfig.uniqueID
            ? Positioned(
                bottom: 10,
                right: 15,
                child: GestureDetector(
                  onTap: onChatButtonPressed,
                  child: Image.asset(
                    "assets/personal_chat_icon.png",
                    width: 30,
                    height: 30,
                    color: Colors.white,
                  ),
                ),
              )
            : const Positioned(top: 0, child: SizedBox()),
      ],
    );
  }

  Widget _buildAvatarAndInfo(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.network(
                "$avatarUrl?${DateTime.now().millisecondsSinceEpoch}",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<PersonalNameNotifier>(
                builder: (BuildContext context, PersonalNameNotifier value,
                    Widget? child) {
                  String name = value.getCachedName(userId);
                  return Text(
                    userId == UserInfoConfig.uniqueID
                        ? UserInfoConfig.userName
                        : name,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
