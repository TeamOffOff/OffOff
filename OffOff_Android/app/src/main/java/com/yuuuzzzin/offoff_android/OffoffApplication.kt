package com.yuuuzzzin.offoff_android

import android.content.Context
import androidx.multidex.MultiDexApplication
import dagger.hilt.android.HiltAndroidApp

/* Hilt 애플리케이션 클래스
* Hilt를 사용하기 위해서는 무조건 @HiltAndroidApp annotation을 가진
* Application 클래스가 존재해야 한다.
* */

@HiltAndroidApp
class OffoffApplication : MultiDexApplication() {

    init {
        instance = this
    }

    companion object {
        private lateinit var instance: OffoffApplication

        fun appCtx(): Context {
            return instance.applicationContext
        }
    }
}