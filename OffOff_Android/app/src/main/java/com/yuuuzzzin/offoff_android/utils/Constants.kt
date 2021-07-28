package com.yuuuzzzin.offoff_android.utils

import android.content.Context
import android.widget.Toast
import androidx.lifecycle.MutableLiveData
import java.util.regex.Pattern

object Constants {

    // 정규표현식
    const val ID_REGEX = "^[A-Za-z0-9]{5,20}\$"
    const val PW_REGEX = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#\$%^&*()_+=-]).{8,16}"
    const val NAME_REGEX = "^[가-힣]{2,10}\$"
    const val EMAIL_REGEX = "(?:[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    const val NICKNAME_REGEX = "/^([a-zA-Z0-9ㄱ-ㅎ|ㅏ-ㅣ|가-힣]).{2,10}"

    // 프로필 사진 설정
    const val PROFILE_OPTION1 = "기본 이미지로 설정"
    const val PROFILE_OPTION2 = "사진 찍기"
    const val PROFILE_OPTION3 = "앨범에서 가져오기"
    const val PROFILE_OPTION4 = "취소"

    // MutableLiveData에 저장된 값 가져오기
    fun MutableLiveData<String>.get(): String {
        return this.value ?: ""
    }

    // 유효성 검사
    fun validate(data: MutableLiveData<String>, regex: String): Boolean {
        return Pattern.compile(regex).matcher(data.get()).matches()

    }

    fun Context.toast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
}