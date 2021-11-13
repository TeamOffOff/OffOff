package com.yuuuzzzin.offoff_android.utils

import android.content.Context
import android.widget.Toast
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import kotlin.math.roundToInt

object Constants {

    const val DATABASE_NAME = "offoff-db"
    const val SCHEDULE_DATA_FILENAME = "schedule.json"

    // 프로필 사진 설정
    const val PROFILE_OPTION1 = "사진 찍기"
    const val PROFILE_OPTION2 = "앨범에서 가져오기"
    const val PROFILE_OPTION3 = "취소"

    const val FROM_ALBUM = 0
    const val FROM_CAMERA = 1


    // 댓글 옵션
    const val DELETE_COMMENT = "삭제"
    const val REPORT_COMMENT = "신고"

    // MutableLiveData에 저장된 값 가져오기
    fun MutableLiveData<String>.get(): String {
        return this.value ?: ""
    }

    fun <T> LiveData<T>.observeOnce(lifecycleOwner: LifecycleOwner, observer: Observer<T>) {
        observe(lifecycleOwner, object : Observer<T> {
            override fun onChanged(t: T?) {
                observer.onChanged(t)
                removeObserver(this)
            }
        })
    }

    fun Context.toast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    fun convertDPtoPX(context: Context, dp: Int): Int {
        val density: Float = context.resources.displayMetrics.density
        return (dp.toFloat() * density).roundToInt()
    }

    fun convertPXtoDP(context: Context, px: Int): Int {
        val density: Float = context.resources.displayMetrics.density
        return (px.toFloat() / density).roundToInt()
    }
}

object PostWriteType {
    const val WRITE = 2 // post 작성
    const val EDIT = 1 // post 수정
}