import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

///图片压缩
class CompressImage {
  Future<File> getImageFileFromAsset(Asset asset) async {
    final byteData = await asset.getByteData();
    final tempFile =
        File('${(await getTemporaryDirectory()).path}/${asset.name}');
    final file = await tempFile.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  Future<XFile> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    String filename = file.path.split('/').last;
    final targetPath = path.join(dir.absolute.path,
        "${DateTime.now().millisecondsSinceEpoch}_temp$filename");
    Logger().w(targetPath);

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return result!;
  }
}
