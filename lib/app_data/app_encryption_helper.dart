import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  static final Key key =
      Key.fromUtf8('YzKl7JzP0xG8jaT09rQwcV1ZbkH6LmNk'); // 32个字符
  static final IV iv = IV.fromUtf8('v7PxD3Nk9MjF2zR4'); // 16个字符

  static final Encrypter _encrypter = Encrypter(AES(key));

  // 加密方法
  static String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  // 解密方法
  static String decrypt(String encryptedText) {
    final decrypted = _encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
