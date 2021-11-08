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

    // 로그인 성공 여부
    private val _loginSuccess = MutableLiveData<Event<String>>()
    val loginSuccess: LiveData<Event<String>> = _loginSuccess

    // 경고 메시지
    private val _alertMsg = MutableLiveData<Event<String>>()
    val alertMsg: LiveData<Event<String>> = _alertMsg

    // 입력받은 정보를 확인해 그에 따른 에러 메시지를 이벤트 처리
    private fun checkInfo(): Boolean {

        var checkValue = true

        // 아이디 값 확인
        if (id.value?.isBlank() == true) {
            _alertMsg.postValue(Event("아이디를 입력해주세요"))
            checkValue = false
        }

        // 비밀번호 값 확인
        if (pw.value?.isBlank() == true) {
            _alertMsg.postValue(Event("비밀번호를 입력해주세요"))
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
                    OffoffApplication.user = response.body()!!.user
                    Log.d("tag_success", "login: ${response.body()}")
                } else {
                    Log.d("tag_fail", "login Error: ${response.code()}")
                    when (response.code()) {
                        NOT_EXIST -> {
                            _alertMsg.postValue(Event("존재하지 않는 아이디입니다."))
                        }
                        WRONG_INFO -> {
                            _alertMsg.postValue(Event("아이디 또는 비밀번호를 확인해주세요."))
                        }
                    }
                }
            }
        }
    }

    companion object {
        const val NOT_EXIST = 403
        const val WRONG_INFO = 401
    }
}