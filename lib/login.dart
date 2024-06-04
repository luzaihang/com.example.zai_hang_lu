import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:zai_hang_lu/loading_page.dart';
import 'package:zai_hang_lu/provider/app_share_data_provider.dart';
import 'package:zai_hang_lu/create_folder.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_acquiesce_data.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_init.dart';
import 'package:zai_hang_lu/tencent/tencent_cloud_list_data.dart';
import 'package:zai_hang_lu/tencent/tencent_upload_download.dart';
import 'package:zai_hang_lu/user_info_data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController notarizePasswordController =
      TextEditingController();
  final TextEditingController cityController = TextEditingController();

  List<Map<String, String>> cityList = [
    {
      "name": "南京一区",
      "region": "ap-nanjing",
      "bucket": "nan-jing-01-1322814250",
    },
    {
      "name": "广州一区",
      "region": "ap-guangzhou",
      "bucket": "guang-zhou-01-1322814250",
    },
    {
      "name": "成都一区",
      "region": "ap-chengdu",
      "bucket": "cheng-du-01-1322814250",
    },
    {
      "name": "北京一区",
      "region": "ap-beijing",
      "bucket": "bei-jing-01-1322814250",
    },
    {
      "name": "上海一区",
      "region": "ap-shanghai",
      "bucket": "shang-hai-01-1322814250",
    },
    {
      "name": "重庆一区",
      "region": "ap-chongqing",
      "bucket": "chong-qing-01-1322814250",
    },
  ];

  String name = ''; //名称
  String password = ''; //密码
  String notarizePassword = ''; //确认密码
  String cityRegion = ""; //地域
  String splice = ""; //要保存的名称、密码
  String? prefix; //前缀
  String? bucket;

  TenCentCloudInit tenCentCloudInit = TenCentCloudInit();
  TencentCloudListData tencentCloudListData = TencentCloudListData();
  UserInfo userInfo = UserInfo();

  ///是否是登录，false为注册
  bool isLogin = true;

  ///是否全部填写好信息，方可下一步
  bool next = false;

  @override
  void initState() {
    //初始化腾讯云cos
    tenCentCloudInit.cloudInit();
    info();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    notarizePasswordController.dispose();
    super.dispose();
  }

  ///如果保存了数据信息，就先用信息填充
  void info() async {
    String info = await userInfo.readUserInfo();
    if (info.isNotEmpty) {
      List<String> fruits = info.split(',');
      nameController.text = fruits[0];
      passwordController.text = fruits[1];
      name = fruits[0];
      password = fruits[1];
    }
  }

  void switchoverLogin() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void getText() {
    Loading().show(context);

    // 检查字段是否为空
    bool areFieldsNotEmpty(bool isLogin) {
      return isLogin
          ? name.isNotEmpty && password.isNotEmpty && cityRegion.isNotEmpty
          : name.isNotEmpty &&
              password.isNotEmpty &&
              notarizePassword.isNotEmpty &&
              password == notarizePassword &&
              cityRegion.isNotEmpty;
    }

    // 更新状态
    void updateState(bool isNext) {
      setState(() {
        next = isNext;
      });
    }

    bool isNext = areFieldsNotEmpty(isLogin);

    if (isNext) {
      splice = "name=$name,password=$password|";
      TencentCloudAcquiesceData.bucket = bucket;
      TencentCloudAcquiesceData.region = cityRegion;
      TencentCloudAcquiesceData.contentName = name;
      tenCentCloudInit.cosXmlServiceConfig();
      userInfo.writeUserInfo("$name,$password");

      Future.delayed(const Duration(seconds: 1), () async {
        /// 状态码 0已注册 1未注册 2其他
        int success = await TencentUpLoadAndDownload().download(splice);
        if (mounted) {
          if (success == 0) {
            Loading().hide();
            //登录
            Navigator.pushReplacementNamed(context, '/home');
          } else if (success == 1) {
            Loading().hide();
            //注册
            Logger().i("请检查账号密码，或暂未注册");
            CreateFolder.getCreateFolder(name, context);
          } else {
            Loading().hide();
            Logger().e("请检查账号密码，或暂未注册");
            return;
          }
        }
      });
    }

    updateState(isNext);
  }

  void _showSelectionDrawer(BuildContext context) async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 400, // 设置抽屉高度
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cityList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(cityList[index]["name"]!),
                onTap: () {
                  Logger().d("${cityList[index]["region"]}");
                  cityRegion = cityList[index]["region"]!;
                  bucket = cityList[index]["bucket"]!;
                  Navigator.pop(context, cityList[index]["name"]);
                },
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        cityController.text = result; // 更新TextField的文本内容
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '昵称',
                      counterText: '',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Colors.blueGrey,
                            width: 2.0), // 设置获取焦点时的边框颜色和宽度
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Colors.grey, width: 1.0), // 设置默认边框颜色和宽度
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: Colors.blueGrey, // 设置获取焦点时的labelText颜色
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\u4e00-\u9fa5]')),
                    ],
                    maxLength: 8,
                    onChanged: (str) {
                      name = str;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: '密码',
                      counterText: '',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Colors.blueGrey,
                            width: 2.0), // 设置获取焦点时的边框颜色和宽度
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Colors.grey, width: 1.0), // 设置默认边框颜色和宽度
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: Colors.blueGrey, // 设置获取焦点时的labelText颜色
                      ),
                    ),
                    maxLength: 15,
                    obscureText: true,
                    onChanged: (str) {
                      password = str;
                      Logger().d(password);
                    },
                  ),
                  !isLogin
                      ? Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: TextField(
                            controller: notarizePasswordController,
                            decoration: InputDecoration(
                              labelText: '确认密码',
                              counterText: '',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.blueGrey,
                                    width: 2.0), // 设置获取焦点时的边框颜色和宽度
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.0), // 设置默认边框颜色和宽度
                              ),
                              floatingLabelStyle: const TextStyle(
                                color: Colors.blueGrey, // 设置获取焦点时的labelText颜色
                              ),
                            ),
                            maxLength: 15,
                            obscureText: true,
                            onChanged: (str) {
                              notarizePassword = str;
                            },
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showSelectionDrawer(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: cityController,
                        readOnly: true, // 确保文本框是只读的
                        decoration: InputDecoration(
                          hintText: '选择临近城市',
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          // 添加下拉箭头图标
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 20, 12, 20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0), // 设置默认边框颜色和宽度
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            Column(
              children: [
                Consumer<AppShareDataProvider>(
                  builder: (BuildContext context, provider, Widget? child) {
                    return GestureDetector(
                      onTap: () => getText(),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 45),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue.withOpacity(0.6),
                        ),
                        child: Text(
                          isLogin ? '登录' : "注册",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    switchoverLogin();
                  },
                  child: Text(
                    isLogin ? '未有账号？注册' : "已有账号，登录",
                    style: TextStyle(
                      color: Colors.blue.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
