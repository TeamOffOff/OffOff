package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.yuuuzzzin.offoff_android.service.repository.AuthRepository
import com.yuuuzzzin.offoff_android.utils.Constants
import com.yuuuzzzin.offoff_android.utils.Event
import com.yuuuzzzin.offoff_android.utils.Strings
import dagger.hilt.android.lifecycle.HiltViewModel
import java.util.regex.Pattern
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
    private var userNickname = ""
    private var userBirth = ""

    // 회원가입 단계별 성공 여부
    private val _step1Success = MutableLiveData<Event<Boolean>>()
    val step1Success: LiveData<Event<Boolean>> = _step1Success

    private val _step2Success = MutableLiveData<Event<Boolean>>()
    val step2Success: LiveData<Event<Boolean>> = _step2Success

    private val _isIdError = MutableLiveData<Event<String>?>()
    val isIdError: MutableLiveData<Event<String>?> = _isIdError

    private val _isPwError = MutableLiveData<Event<String>>()
    val isPwError: LiveData<Event<String>> = _isPwError

    private val _isPwConfirmError = MutableLiveData<Event<String>>()
    val isPwConfirmError: LiveData<Event<String>> = _isPwConfirmError

    private val _isNameError = MutableLiveData<Event<String>>()
    val isNameError: LiveData<Event<String>> = _isNameError

    private val _isEmailError = MutableLiveData<Event<String>>()
    val isEmailError: LiveData<Event<String>> = _isEmailError

    private val _isBirthError = MutableLiveData<Event<String>>()
    val isBirthError: LiveData<Event<String>> = _isBirthError

    private val _isNicknameError = MutableLiveData<Event<String>>()
    val isNicknameError: LiveData<Event<String>> = _isNicknameError

    // 입력받은 정보가 모두 조건에 만족했는지지 완료었는지 여부
    private val _infoChecked = MutableLiveData<Event<Unit>>()
    val infoChecked: LiveData<Event<Unit>> = _infoChecked

    fun validateId(): Boolean {

        if (id.value?.isBlank() == true || !Pattern.matches(Constants.ID_REGEX, id.value!!)) {
            Log.d("focusloose_tag", id.value.toString())
            _isIdError.value = Event(Strings.id_error)
            return false
        } else {
            _isIdError.value = Event("")
            Log.d("focusloose_tag", "패턴맞음")
            userId = id.value!!
        }

        return true
    }

    fun validatePw(): Boolean {

        if (pw.value?.isBlank() == true || !Pattern.matches(Constants.PW_REGEX, pw.value!!)) {
            Log.d("focusloose_tag", id.value.toString())
            _isPwError.value = Event(Strings.pw_error)
            return false
        } else {
            _isPwError.value = Event("")
        }

        return true
    }

    fun validatePwConfirm(): Boolean {

        if (pwConfirm.value?.isBlank() == true || pw.value != pwConfirm.value) {
            _isPwConfirmError.value = Event(Strings.pw_confirm_error)
            return false
        } else {
            _isPwConfirmError.value = Event("")
            userPw = pw.value!!
        }

        return true
    }

    fun validateName(): Boolean {

        if (name.value?.isBlank() == true || !Pattern.matches(Constants.NAME_REGEX, name.value!!)) {
            _isNameError.value = Event(Strings.name_error)
            return false
        } else {
            _isNameError.value = Event("")
            Log.d("focusloose_tag", "패턴맞음")
            userName = name.value!!
        }

        return true
    }

    fun validateEmail(): Boolean {

        if (email.value?.isBlank() == true || !Pattern.matches(
                Constants.EMAIL_REGEX,
                email.value!!
            )
        ) {
            Log.d("focusloose_tag", email.value.toString())
            _isEmailError.value = Event(Strings.email_error)
            return false
        } else {
            _isEmailError.value = Event("")
            Log.d("focusloose_tag", "패턴맞음")
            userEmail = email.value!!
        }

        return true
    }

    fun validateBirth(): Boolean {

        if (birth.value?.isBlank() == true) {
            Log.d("focusloose_tag", birth.value.toString())
            _isBirthError.value = Event(Strings.birth_error)
            return false
        } else {
            _isBirthError.value = Event("")
            Log.d("focusloose_tag", "패턴맞음")
            userBirth = birth.value!!
        }

        return true
    }

    fun validateNickname(): Boolean {

        if (nickname.value?.isBlank() == true || !Pattern.matches(
                Constants.NICKNAME_REGEX,
                nickname.value!!
            )
        ) {
            Log.d("focusloose_tag", nickname.value.toString())
            //_isNicknameError.value = Event()
            return false
        } else {
            _isNicknameError.value = Event("")
            Log.d("focusloose_tag", "패턴맞음")
            userNickname = nickname.value!!
        }

        return true
    }

    fun finishStep1() {
        _step1Success.postValue(Event(true))

//        if((userId!="" && userPw!="")&&
//            (id.value == userId && pw.value == userPw && pwConfirm.value == userPw)) {
//            _step1Success.postValue(Event(true))
//        }
//        else {
//            validateId()
//            validatePw()
//            validatePwConfirm()
//        }
    }

    fun finishStep2() {
        _step2Success.postValue(Event(true))
        if ((userName != "" && userEmail != "" && userBirth != "") &&
            (name.value == userName && email.value == userEmail) //  && birth.value == userBirth
        ) {
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

    fun getUserPw(): String {
        return userPw
    }

}