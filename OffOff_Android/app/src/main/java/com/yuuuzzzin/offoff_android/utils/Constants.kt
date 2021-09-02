package com.yuuuzzzin.offoff_android.utils

import android.content.Context
import android.widget.Toast
import androidx.lifecycle.MutableLiveData

object Constants {

    const val DATABASE_NAME = "offoff-db"
    const val SCHEDULE_DATA_FILENAME = "schedule.json"

    // 프로필 사진 설정
    const val PROFILE_OPTION1 = "기본 이미지로 설정"
    const val PROFILE_OPTION2 = "사진 찍기"
    const val PROFILE_OPTION3 = "앨범에서 가져오기"
    const val PROFILE_OPTION4 = "취소"

    // MutableLiveData에 저장된 값 가져오기
    fun MutableLiveData<String>.get(): String {
        return this.value ?: ""
    }

    fun Context.toast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
}

object PostWriteType {
    const val WRITE = 0 // post 작성
    const val EDIT = 1 // post 수정
}