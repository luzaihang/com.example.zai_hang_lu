import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/provider/my_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarWidget extends StatefulWidget {
  final String userId;
  final String? meNewAvatarUrl;

  ///获取头像
  const AvatarWidget({super.key, required this.userId, this.meNewAvatarUrl});

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  String url = '';

  @override
  void initState() {
    super.initState();
    _loadAvatarUrl();
  }

  @override
  void didUpdateWidget(covariant AvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAvatarUrl();
  }

  Future<void> _loadAvatarUrl() async {
    if (widget.userId == UserInfoConfig.uniqueID) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedAvatarUrl = prefs.getString('cachedAvatarUrl');

      if (mounted && savedAvatarUrl != null) {
        url = savedAvatarUrl;
        setState(() {});
      }
    }
  }

  Future<void> _updateAvatarUrl() async {
    if (widget.meNewAvatarUrl != null && widget.meNewAvatarUrl!.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedAvatarUrl', widget.meNewAvatarUrl!);
      url = widget.meNewAvatarUrl!;

      if (mounted) {
        final provider = context.read<MyPageNotifier>();
        provider.newAvatarUrl = '';
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        height: 40,
        width: 40,
        child: Image(
          image: CachedNetworkImageProvider(
            url.isNotEmpty
                ? url
                : "${DefaultConfig.avatarAndPostPrefix}/${widget.userId}/userAvatar.png",
            maxHeight: 200,
            maxWidth: 200,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
