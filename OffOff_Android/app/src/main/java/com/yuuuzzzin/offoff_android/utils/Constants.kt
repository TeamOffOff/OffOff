package com.yuuuzzzin.offoff_android.utils

import android.content.Context
import android.widget.Toast
import androidx.lifecycle.MutableLiveData

object Constants {

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