package com.example.zai_hang_lu

import android.os.Build
import cn.leancloud.LCLogger
import cn.leancloud.LeanCloud
import cn.leancloud.im.LCIMOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.zai_hang_lu"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        LCIMOptions.getGlobalOptions().setUnreadNotificationEnabled(true);
        //开启调试日志
        LeanCloud.setLogLevel(LCLogger.Level.DEBUG);
        // 提供 this、App ID、App Key、Server URL 作为参数
        // 请将 your_server_url 替换为你的应用绑定的 API 域名
        LeanCloud.initialize(
            this,
            "4pAbS2RXdM9PLvHXGgFUrGe1-gzGzoHsz",
            "0MLmh4Q04UxZuXgGvaDV6mHx",
            "4pabs2rx.lc-cn-n1-shared.com"
        );

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSystemVersion") {
                val version = Build.VERSION.SDK_INT
                result.success(version)
            } else {
                result.notImplemented()
            }
        }
    }
}
