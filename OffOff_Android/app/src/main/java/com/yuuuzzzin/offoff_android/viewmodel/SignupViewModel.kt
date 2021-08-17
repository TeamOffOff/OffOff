package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.*
import com.yuuuzzzin.offoff_android.service.models.Activity
import com.yuuuzzzin.offoff_android.service.models.Info
import com.yuuuzzzin.offoff_android.service.models.SubInfo
import com.yuuuzzzin.offoff_android.service.models.User
import com.yuuuzzzin.offoff_android.service.repository.MemberRepository
import com.yuuuzzzin.offoff_android.utils.Constants.get
import com.yuuuzzzin.offoff_android.utils.Event
import com.yuuuzzzin.offoff_android.utils.SignupUtils.BIRTH_ERROR
import com.yuuuzzzin.offoff_android.utils.SignupUtils.EMAIL_DUP
import com.yuuuzzzin.offoff_android.utils.SignupUtils.EMAIL_ERROR
import com.yuuuzzzin.offoff_android.utils.SignupUtils.EMAIL_REGEX
import com.yuuuzzzin.offoff_android.utils.SignupUtils.ID_DUP
import com.yuuuzzzin.offoff_android.utils.SignupUtils.ID_ERROR
import com.yuuuzzzin.offoff_android.utils.SignupUtils.ID_REGEX
import com.yuuuzzzin.offoff_android.utils.SignupUtils.NAME_ERROR
import com.yuuuzzzin.offoff_android.utils.SignupUtils.NAME_REGEX
import com.yuuuzzzin.offoff_android.utils.SignupUtils.NICKNAME_ERROR
import com.yuuuzzzin.offoff_android.utils.SignupUtils.NICKNAME_REGEX
import com.yuuuzzzin.offoff_android.utils.SignupUtils.NICKNAME_VALID
import com.yuuuzzzin.offoff_android.utils.SignupUtils.PW_CONFIRM_ERROR
import com.yuuuzzzin.offoff_android.utils.SignupUtils.PW_ERROR
import com.yuuuzzzin.offoff_android.utils.SignupUtils.PW_REGEX
import com.yuuuzzzin.offoff_android.utils.SignupUtils.validate
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SignupViewModel
@Inject
constructor(
    private val repository: MemberRepository
) : ViewModel() {

    val id: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }
    val pw: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }
    val pwConfirm: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }
    val name: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }
    val email: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }
    val birth: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }
    val nickname: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }

    private var userId = ""
    private var userPw = ""
    private var userName = ""
    private var userEmail = ""
    private var userBirth = ""
    private var userNickname = ""

    // 입력 항목별 verified 여부
    private val _isIdVerified = MutableLiveData<String>()
    val isIdVerified: LiveData<String> get() = _isIdVerified

    private val _isPwVerified = MutableLiveData<String>()
    val isPwVerified: LiveData<String> get() = _isPwVerified

    private val _isPwConfirmVerified = MutableLiveData<String>()
    val isPwConfirmVerified: LiveData<String> get() = _isPwConfirmVerified

    private val _isNameVerified = MutableLiveData<String>()
    val isNameVerified: LiveData<String> get() = _isNameVerified

    private val _isEmailVerified = MutableLiveData<String>()
    val isEmailVerified: LiveData<String> get() = _isEmailVerified

    private val _isBirthVerified = MutableLiveData<String>()
    val isBirthVerified: LiveData<String> get() = _isBirthVerified

    private val _isNicknameVerified = MutableLiveData<String>()
    val isNicknameVerified: LiveData<String> get() = _isNicknameVerified

    private val _isNicknameError = MutableLiveData<String>()
    val isNicknameError: LiveData<String> get() = _isNicknameError

    // 회원가입 단계별 성공 여부
    private val _step1Success = combine(
        isIdVerified.asFlow(),
        isPwVerified.asFlow(),
        isPwConfirmVerified.asFlow()
    ) { id, pw, pwConfirm ->
        id == "" && pw == "" && pwConfirm == ""
    }.onStart { emit(false) }.asLiveData()
    val step1Success: LiveData<Boolean> get() = _step1Success

    private val _step2Success = combine(
        isNameVerified.asFlow(),
        isEmailVerified.asFlow(),
        isBirthVerified.asFlow()
    ) { name, email, birth ->
        name == "" && email == "" && birth == ""
    }.onStart { emit(false) }.asLiveData()
    val step2Success: LiveData<Boolean> get() = _step2Success

    private val _step3Success = MutableLiveData<Event<Boolean>>()
    val step3Success: LiveData<Event<Boolean>> = _step3Success

    fun validateId() {
        if (!validate(id, ID_REGEX)) {
            _isIdVerified.postValue(ID_ERROR)
        } else {
            checkId(id.value!!)
        }
    }

    private fun checkId(id: String) = viewModelScope.launch(Dispatchers.IO) {
        repository.checkId(id).let { response ->
            if (response.isSuccessful) {
                _isIdVerified.postValue("")
                userId = id
                Log.d("tag_success", "checkId: ${response.body()}")
            } else {
                _isIdVerified.postValue(ID_DUP)
                Log.d("tag_fail", "checkId Error: ${response.code()}")
            }
        }
    }

    fun validatePw() {
        if (!validate(pw, PW_REGEX)) {
            _isPwVerified.postValue(PW_ERROR)
        } else {
            _isPwVerified.postValue("")
        }
    }

    fun validatePwConfirm() {
        if (pwConfirm.get().isNullOrEmpty() || pw.get() != pwConfirm.get()) {
            _isPwConfirmVerified.postValue(PW_CONFIRM_ERROR)
        } else {
            _isPwConfirmVerified.postValue("")
            userPw = pw.value!!
        }
    }

    fun validateName() {
        if (!validate(name, NAME_REGEX)) {
            _isNameVerified.postValue(NAME_ERROR)
        } else {
            _isNameVerified.postValue("")
            userName = name.value!!
        }
    }

    fun validateEmail() {
        if (!validate(email, EMAIL_REGEX)) {
            _isEmailVerified.postValue(EMAIL_ERROR)
        } else {
            checkEmail(email.value!!)
        }
    }

    private fun checkEmail(email: String) = viewModelScope.launch(Dispatchers.IO) {
        repository.checkEmail(email).let { response ->
            if (response.isSuccessful) {
                _isEmailVerified.postValue("")
                userEmail = email
                Log.d("tag_success", response.body().toString())
            } else {
                _isEmailVerified.postValue(EMAIL_DUP)
                Log.d("tag_fail", "checkEmail Error: ${response.code()}")
            }
        }
    }

    fun validateBirth() {
        if (birth.value?.isBlank() == true) {
            _isBirthVerified.postValue(BIRTH_ERROR)
        } else {
            _isBirthVerified.postValue("")
            userBirth = birth.value!!
        }
    }

    fun validateNickname() {
        if (!validate(nickname, NICKNAME_REGEX)) {
            _isNicknameError.postValue(nickname.get() + NICKNAME_ERROR)
        } else {
            checkNickname(nickname.value!!)
        }
    }

    private fun checkNickname(nickname: String) = viewModelScope.launch(Dispatchers.IO) {
        repository.checkNickname(nickname).let { response ->
            if (response.isSuccessful) {
                userNickname = nickname
                _isNicknameVerified.postValue(nickname + NICKNAME_VALID)
                Log.d("tag_success", "checkNickname: ${response.body()}")
            } else {
                _isNicknameError.postValue(nickname + NICKNAME_ERROR)
                Log.d("tag_fail", "checkNickname Error: ${response.code()}")
            }
        }
    }

    fun finishStep3() {
        if (userNickname != "" && (nickname.value == userNickname)) {
            signup()

            Log.d(
                "tag_success 3단계",
                userId + "/" + userPw + "/" + userName + "/" + userEmail + "/" + userBirth + "/" + userNickname
            )

        } else {
            validateNickname()
        }
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
fun signup() {

        val user = User(
            id = userId, password = userPw,
            Info(name = userName, email = userEmail, birth = userBirth),
            SubInfo(nickname = userNickname),
            Activity()
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.signup(user).let { response ->
                if (response.isSuccessful) {
                    Log.d("tag_success", "signup: ${response.body()}")
                    _step3Success.postValue(Event(true))
                } else {
                    Log.d("tag_fail", "signup Error: ${response.code()}")
                }
            }
        }
    }
}