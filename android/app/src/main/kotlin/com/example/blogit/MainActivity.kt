package app.signal.flutter

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.signal/screen_wake_lock"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

       flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
         MethodChannel(messenger, CHANNEL).setMethodCallHandler {  call, result ->
            when (call.method) {
                "enableWakelock" -> {
                    enableWakelock()
                    result.success(null)
                }
                "disableWakelock" -> {
                    disableWakelock()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
         }
        }
    }

    private fun enableWakelock() {
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    private fun disableWakelock() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}