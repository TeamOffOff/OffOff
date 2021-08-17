package com.yuuuzzzin.offoff_android.utils

import androidx.lifecycle.MutableLiveData
import com.yuuuzzzin.offoff_android.utils.Constants.get
import java.util.regex.Pattern

object SignupUtils {

    // 정규표현식
    const val ID_REGEX = "^[A-Za-z0-9]{5,20}\$"
    const val PW_REGEX = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#\$%^&*()_+=-]).{8,16}"
    const val NAME_REGEX = "^[가-힣]{2,10}\$"
    const val EMAIL_REGEX = "(?:[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    const val NICKNAME_REGEX = "^[가-힣A-Za-z0-9]{2,10}\$"

    // 에러 메시지
    const val ID_ERROR = "아이디는 5-20자의 영문, 숫자만 사용 가능합니다."
    const val ID_DUP = "이미 사용 중인 아이디입니다."
    const val PW_ERROR = "비밀번호는 8-16자의 영문, 숫자, 기호만 사용 가능합니다."
    const val PW_CONFIRM_ERROR = "비밀번호가 일치하지 않습니다."
    const val NAME_ERROR = "올바른 형식의 이름이 아닙니다."
    const val EMAIL_ERROR = "올바른 형식의 이메일이 아닙니다."
    const val EMAIL_DUP = "이미 사용 중인 이메일입니다."
    const val BIRTH_ERROR = "생년월일을 입력해주세요."
    const val NICKNAME_ERROR = " 은(는) 사용할 수 없습니다."
    const val NICKNAME_VALID = " 은(는) 사용가능한 닉네임입니다."

    // 정규식 검사
    fun validate(data: MutableLiveData<String>, regex: String): Boolean {
        return Pattern.compile(regex).matcher(data.get()).matches()
    }
}