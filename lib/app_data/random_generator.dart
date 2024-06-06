import 'dart:math';

class RandomGenerator {
  static final Random _rnd = Random();

  // 生成一个随机数字字符
  static String getRandomNumber() {
    return _rnd.nextInt(10).toString(); // 生成0到9之间的数字
  }

  // 生成一个随机英文字符
  static String getRandomLetter() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    return letters[_rnd.nextInt(letters.length)];
  }

  /// 生成一个包含6个随机数字和4个随机字母的组合
  static String getRandomCombination() {
    List<String> parts = List.generate(6, (_) => getRandomNumber()) +
        List.generate(4, (_) => getRandomLetter());
    parts.shuffle(_rnd); // 打乱组合顺序
    return parts.join();
  }
}