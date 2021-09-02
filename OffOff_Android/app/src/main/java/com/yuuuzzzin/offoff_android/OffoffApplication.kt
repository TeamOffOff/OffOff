package com.yuuuzzzin.offoff_android

import android.content.Context
import androidx.multidex.MultiDexApplication
import com.yuuuzzzin.offoff_android.service.SharedPreferenceController
import dagger.hilt.android.HiltAndroidApp
import io.realm.Realm
import io.realm.RealmConfiguration

@HiltAndroidApp
class OffoffApplication : MultiDexApplication() {

    override fun onCreate() {
        super.onCreate()
        pref = SharedPreferenceController(applicationContext)

        // Realm 초기화
        Realm.init(this)
        val config : RealmConfiguration = RealmConfiguration.Builder()
            .allowWritesOnUiThread(true)
            .name("schedule.realm")
            .deleteRealmIfMigrationNeeded()
            .build()

        Realm.setDefaultConfiguration(config)
    }

    init {
        instance = this
    }

    companion object {
        private lateinit var instance: OffoffApplication
        lateinit var pref: SharedPreferenceController

        fun appCtx(): Context {
            return instance.applicationContext
        }
    }
}