package com.prokurs.app

import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable edge-to-edge display for Android 11+ (SDK 30+)
        // setDecorFitsSystemWindows is available from API 30
        // For Android 15+ (SDK 35+), edge-to-edge is enabled by default
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        }
    }
}
