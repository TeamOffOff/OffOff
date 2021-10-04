package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.LoginInfo
import com.yuuuzzzin.offoff_android.service.repository.MemberRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class LoginViewModel
@Inject
constructor(
    private val repository: MemberRepository
) : ViewModel() {

    val id = MutableLiveData("")
    val pw = MutableLiveData("")
    val alertMsg = MutableLiveData("")

    // 로그인 성공 여부
    private val _loginSuccess = MutableLiveData<Event<String>>()
    val loginSuccess: LiveData<Event<String>> = _loginSuccess

    // 로그인 실패 메시지
    private val _loginFail = MutableLiveData<Event<String>>()
    val loginFail: LiveData<Event<String>> = _loginFail

    private val _isIdError = MutableLiveData<Event<String>>()
    val isIdError: LiveData<Event<String>> = _isIdError

    private val _isPwError = MutableLiveData<Event<String>>()
    val isPwError: LiveData<Event<String>> = _isPwError

    // 입력받은 정보를 확인해 그에 따른 에러 메시지를 이벤트 처리
    private fun checkInfo(): Boolean {

        var checkValue = true

        // 아이디 값 확인
        if (id.value?.isBlank() == true) {
            _isIdError.value = Event("아이디를 입력해주세요")
            checkValue = false
        }

        // 비밀번호 값 확인
        if (pw.value?.isBlank() == true) {
            _isPwError.value = Event("비밀번호를 입력해주세요")
            checkValue = false
        }

        return checkValue
    }

    fun login() {
        if (!checkInfo()) return

        val userId = id.value ?: return
        val userPw = pw.value ?: return
        val loginInfo = LoginInfo(userId, userPw)

        viewModelScope.launch(Dispatchers.IO) {
            repository.login(loginInfo).let { response ->
                if (response.isSuccessful) {
                    _loginSuccess.postValue(Event(userId))
                    OffoffApplication.pref.token = "Bearer " + response.body()!!.accessToken
                    Log.d("tag_success", "login: ${response.body()}")
                    Log.d("tag_success", "token: ${OffoffApplication.pref.token}")
                } else {
                    Log.d("tag_fail", "login Error: ${response.code()}")
                    when (response.code()) {
                        NOT_EXIST -> {
                            _isIdError.postValue(Event("존재하지 않는 아이디입니다."))
                        }
                        WRONG_INFO -> _loginFail.postValue(Event("아이디와 비밀번호를 확인해주세요."))
                    }
                }
            }
        }
    }

    companion object {
        const val NOT_EXIST = 404
        const val WRONG_INFO = 500
    }
}