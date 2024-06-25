import 'package:ci_dong/app_data/random_generator.dart';
import 'package:ci_dong/factory_list/personal_folder_from_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///点击文件夹时的弹窗
void showActionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 20), // 去除内边距
            child: Column(
              mainAxisSize: MainAxisSize.min, // 对话框内容的最小尺寸
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  // 指定键盘类型为数字
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly // 只允许输入数字
                  ],
                  cursorColor: const Color(0xFF052D84),
                  // 设置光标的颜色
                  cursorRadius: const Radius.circular(10),
                  // 设置光标的圆角
                  style: const TextStyle(
                    fontSize: 16, // 输入后的字号
                    color: Colors.red, // 输入后的颜色
                  ),
                  textAlign: TextAlign.center,
                  // 使输入的文本居中对齐
                  decoration: InputDecoration(
                    hintText: '联系贴主并输入密码可直接进入',
                    // 设置提示文本
                    hintStyle: TextStyle(
                      fontSize: 13, // 提示文本的字号
                      color: const Color(0xFF052D84).withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    // 不要边框
                    contentPadding: const EdgeInsets.all(0),
                    // 不要内边距
                    counterText: "",
                  ),
                  maxLength: 6,
                ),
                Divider(
                  color: const Color(0xFF052D84).withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "20次豆进入",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF052D84),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "密码进入",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

///图册添加时的弹窗（文件夹名、密码）
Future<dynamic> showFolderAddDialog(BuildContext context) async {
  String folderName = '';
  String folderPassword = '';
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 20), // 去除内边距
            child: Column(
              mainAxisSize: MainAxisSize.min, // 对话框内容的最小尺寸
              children: [
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[\u4e00-\u9fa5a-zA-Z]'), // 允许输入的字符范围：中文字符和英文字母
                    ),
                  ],
                  cursorColor: const Color(0xFF052D84),
                  // 设置光标的颜色
                  cursorRadius: const Radius.circular(10),
                  // 设置光标的圆角
                  style: const TextStyle(
                    fontSize: 16, // 输入后的字号
                    color: Color(0xFF052D84), // 输入后的颜色
                  ),
                  textAlign: TextAlign.center,
                  // 使输入的文本居中对齐
                  decoration: InputDecoration(
                    hintText: '文件夹名称(不可更改)',
                    // 设置提示文本
                    hintStyle: TextStyle(
                      fontSize: 13, // 提示文本的字号
                      color: const Color(0xFF052D84).withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    // 不要边框
                    contentPadding: const EdgeInsets.all(0),
                    // 不要内边距
                    counterText: "",
                  ),
                  maxLength: 6,
                  onChanged: (n) {
                    folderName = n;
                  },
                ),

                //
                TextField(
                  keyboardType: TextInputType.number,
                  // 指定键盘类型为数字
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly // 只允许输入数字
                  ],
                  cursorColor: const Color(0xFF052D84),
                  // 设置光标的颜色
                  cursorRadius: const Radius.circular(10),
                  // 设置光标的圆角
                  style: const TextStyle(
                    fontSize: 16, // 输入后的字号
                    color: Colors.red, // 输入后的颜色
                  ),
                  textAlign: TextAlign.center,
                  // 使输入的文本居中对齐
                  decoration: InputDecoration(
                    hintText: '文件夹密码(可空)',
                    // 设置提示文本
                    hintStyle: TextStyle(
                      fontSize: 13, // 提示文本的字号
                      color: const Color(0xFF052D84).withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    // 不要边框
                    contentPadding: const EdgeInsets.all(0),
                    // 不要内边距
                    counterText: "",
                  ),
                  maxLength: 6,
                  onChanged: (p) {
                    folderPassword = p;
                  },
                ),
                //
                Divider(
                  color: const Color(0xFF052D84).withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    String folderId = RandomGenerator.getRandomCombination();
                    PersonalFolderFromMap folderFromMap;
                    folderFromMap = PersonalFolderFromMap(
                      folderName: folderName,
                      folderPassword: folderPassword,
                      folderId: folderId,
                      fondNameList: '',
                      creationTime: DateTime.now().toString(),
                      images: [],
                      folderIntegral: 0,
                    );
                    Navigator.pop(context, folderFromMap);
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "确认",
                      style: TextStyle(
                        fontSize: 16, // 输入后的字号
                        color: Color(0xFF052D84), // 输入后的颜色
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
