package com.yuuuzzzin.offoff_android.utils

import android.util.Log

object LogUtils {

    fun logCoroutineThread() =
        Log.d("tag_currentThread", "현재 스레드 : " + Thread.currentThread().name)

}