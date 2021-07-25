package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.yuuuzzzin.offoff_android.service.repository.AuthRepository
import com.yuuuzzzin.offoff_android.utils.Constants.EMAIL_REGEX
import com.yuuuzzzin.offoff_android.utils.Constants.ID_REGEX
import com.yuuuzzzin.offoff_android.utils.Constants.NAME_REGEX
import com.yuuuzzzin.offoff_android.utils.Constants.NICKNAME_REGEX
import com.yuuuzzzin.offoff_android.utils.Constants.PW_REGEX
import com.yuuuzzzin.offoff_android.utils.Constants.get
import com.yuuuzzzin.offoff_android.utils.Constants.validate
import com.yuuuzzzin.offoff_android.utils.Event
import com.yuuuzzzin.offoff_android.utils.Strings
import com.yuuuzzzin.offoff_android.utils.Strings.id_error
import com.yuuuzzzin.offoff_android.utils.Strings.pw_confirm_error
import com.yuuuzzzin.offoff_android.utils.Strings.pw_error
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class SignupViewModel
@Inject
constructor(
    private val repository: AuthRepository
) : ViewModel() {

    val id = MutableLiveData("")
    val pw = MutableLiveData("")
    val pwConfirm = MutableLiveData("")
    val name = MutableLiveData("")
    val email = MutableLiveData("")
    val nickname = MutableLiveData("")
    val birth = MutableLiveData("")

    private var userId = ""
    private var userPw = ""
    private var userName = ""
    private var userEmail = ""
    private var userBirth = ""
    private var userNickname = ""

    // 회원가입 단계별 성공 여부
    private val _step1Success = MutableLiveData<Event<Boolean>>()
    val step1Success: LiveData<Event<Boolean>> = _step1Success

    private val _step2Success = MutableLiveData<Event<Boolean>>()
    val step2Success: LiveData<Event<Boolean>> = _step2Success

    private val _step3Success = MutableLiveData<Event<Boolean>>()
    val step3Success: LiveData<Event<Boolean>> = _step3Success

    // 입력 항목별 verified 여부
    private val _isIdVerified = MutableLiveData<Event<String>?>()
    val isIdVerified: MutableLiveData<Event<String>?> = _isIdVerified

    private val _isPwVerified = MutableLiveData<Event<String>?>()
    val isPwVerified: MutableLiveData<Event<String>?> = _isPwVerified

    private val _isPwConfirmVerified = MutableLiveData<Event<String>?>()
    val isPwConfirmVerified: MutableLiveData<Event<String>?> = _isPwConfirmVerified

    private val _isNameVerified = MutableLiveData<Event<String>?>()
    val isNameVerified: MutableLiveData<Event<String>?> = _isNameVerified

    private val _isEmailVerified = MutableLiveData<Event<String>?>()
    val isEmailVerified: MutableLiveData<Event<String>?> = _isEmailVerified

    private val _isBirthVerified = MutableLiveData<Event<String>?>()
    val isBirthVerified: MutableLiveData<Event<String>?> = _isBirthVerified

    private val _isNicknameVerified = MutableLiveData<Event<String>?>()
    val isNicknameVerified: MutableLiveData<Event<String>?> = _isNicknameVerified

    private val _isNicknameError = MutableLiveData<Event<String>?>()
    val isNicknameError: MutableLiveData<Event<String>?> = _isNicknameError

    // 유효성 검사
    fun validateId() {

        if (!validate(id, ID_REGEX)) {
            _isIdVerified.value = Event(id_error)
        } else {
            _isIdVerified.value = Event("")
            userId = id.value!!
        }
    }

    fun validatePw() {

        if (!validate(pw, PW_REGEX)) {
            _isPwVerified.value = Event(pw_error)
        } else {
            _isPwVerified.value = Event("")
        }
    }

    fun validatePwConfirm() {

        if (pwConfirm.get().isNullOrEmpty() || pw.get() != pwConfirm.get()) {
            _isPwConfirmVerified.value = Event(pw_confirm_error)
        } else {
            _isPwConfirmVerified.value = Event("")
            userPw = pw.value!!
        }
    }

    fun validateName() {

        if (!validate(name, NAME_REGEX)) {
            _isNameVerified.value = Event(Strings.name_error)
        } else {
            _isNameVerified.value = Event("")
            userName = name.value!!
        }
    }

    fun validateEmail() {

        if (!validate(email, EMAIL_REGEX)) {
            _isEmailVerified.value = Event(Strings.email_error)
        } else {
            _isEmailVerified.value = Event("")
            userEmail = email.value!!
        }
    }

    fun validateBirth() {

        if (birth.value?.isBlank() == true) {
            _isBirthVerified.value = Event(Strings.birth_error)
        } else {
            _isBirthVerified.value = Event("")
            userBirth = birth.value!!
        }
    }

    fun validateNickname() {

        if (!validate(nickname, NICKNAME_REGEX)) {
            Log.d("tag_닉넴유효성불통", nickname.get())
            _isNicknameError.value = Event(nickname.get() + "은(는) 사용할 수 없습니다.")
        } else {
            Log.d("tag_닉넴유효성통", nickname.get())
            _isNicknameVerified.value = Event(nickname.get() + "은(는) 사용 가능한 닉네임입니다.")
            //userNickname = nickname.value!!
        }
    }

    fun finishStep1() {
        //_step1Success.postValue(Event(true))
        if((userId!="" && userPw!="")&&
            (id.value == userId && pw.value == userPw && pwConfirm.value == userPw)) {
            _step1Success.postValue(Event(true))
        }
        else {
            validateId()
            validatePw()
            validatePwConfirm()
        }
    }

    fun finishStep2() {
        //_step2Success.postValue(Event(true))
        if ((userName != "" && userEmail != "" && userBirth != "") &&
            (name.value == userName && email.value == userEmail)) {
            _step2Success.postValue(Event(true))
        } else {
            validateName()
            validateEmail()
            validateBirth()
        }
    }

    fun finishStep3() {

    }

    fun setStep1State(): Boolean {
        return (userId != "")
    }

    fun setStep2State(): Boolean {
        return (userName != "")
    }

    // 비밀번호 입력칸의 문자열이 비밀번호 확인 입력칸에 문자열이 존재할 때
    // 변동이 생긴다면 -> 비밀번호 확인 칸 리셋
    // 하기 위해 비교
    fun comparePw(): Boolean {
        return (pw.value == pwConfirm.value)
    }
}