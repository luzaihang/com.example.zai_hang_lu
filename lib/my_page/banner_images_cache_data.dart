import 'package:shared_preferences/shared_preferences.dart';

class BannerImageCache {
  /// 从 SharedPreferences 加载列表数据
  Future<List<String>> loadBannerImgList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('bannerImgList') ?? [];
  }

  /// 存储列表数据到 SharedPreferences
  Future<void> saveBannerImgList(List<String> bannerImgList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bannerImgList', bannerImgList);
  }
}
