package com.prokurs.app

import android.app.Application

import com.yandex.mapkit.MapKitFactory


class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        MapKitFactory.setApiKey(BuildConfig.YANDEX_API_KEY);
    }
}