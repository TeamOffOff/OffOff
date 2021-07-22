package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.LoginInfo
import com.yuuuzzzin.offoff_android.service.repository.AuthRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.regex.Pattern
import javax.inject.Inject

@HiltViewModel
class LoginViewModel
@Inject
constructor(
    private val repository: AuthRepository
): ViewModel() {

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

    // 입력받은 정보가 모두 조건에 만족했는지지 완료었는지 여부
    private val _infoChecked = MutableLiveData<Event<Unit>>()
    val infoChecked: LiveData<Event<Unit>> = _infoChecked

    // 입력받은 정보를 확인해 그에 따른 에러 메시지를 이벤트 처리
    private fun checkInfo(): Boolean {

        var checkValue = true

        // 아이디 값 확인
        if(id.value?.isBlank() == true) {
            _isIdError.value = Event("아이디를 입력해주세요")
            checkValue = false
        }
        else if(!Pattern.matches("^[a-zA-Z0-9]{5,15}\$", id.value!!)) {
            _isIdError.value = Event("아이디는 영문과 숫자를 조합한 5~15글자")
            checkValue = false
        }
        // 비밀번호 값 확인
        if(pw.value?.isBlank() == true) {
            _isPwError.value = Event("비밀번호를 입력해주세요")
            checkValue = false
        }

        return checkValue
    }

    fun login() {
        if (!checkInfo()) return

        val userId = id.value ?: return
        val userPw = pw.value ?: return

        // 입력받은 id와 pw를 서버에 보내고 응답받기
        viewModelScope.launch(Dispatchers.IO) {
            repository.login(LoginInfo(userId, userPw)).let { response ->
                // 서버 통신 성공
                if(response.isSuccessful) {
                    // 로그인 성공
                    if(response.body()!!.result == "success") {
                        _loginSuccess.postValue(Event(userId))
                        Log.d("tag_login_success", response.body().toString())
                    } else { // 로그인 실패
                        Log.d("tag_login_fail", response.body().toString())
                        //alertMsg.postValue(response.body()!!.result)
                        _loginFail.postValue(Event(response.body()!!.result))
                    }
                    // 서버 통신 실패
                } else {
                    Log.d("tag_server_fail", "서버 통신 실패: ${response.code()}")
                }
            }
        }
    }
}