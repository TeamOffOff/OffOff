package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.LoginInfo
import com.yuuuzzzin.offoff_android.service.repository.AuthRepository
import com.yuuuzzzin.offoff_android.util.Event
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

    private val _loginSuccessEvent = MutableLiveData<Event<String>>()
    val loginSuccessEvent: LiveData<Event<String>>
        get() = _loginSuccessEvent

    val id: MutableLiveData<String> by lazy {
        MutableLiveData<String>().apply {
            postValue("")
        }
    }
    val pw: MutableLiveData<String> by lazy {
        MutableLiveData<String>().apply {
            postValue("")
        }
    }
    val alertMsg:MutableLiveData<String> by lazy {
        MutableLiveData<String>().apply {
            //postValue("")
        }
    }
    val alertId:MutableLiveData<String> by lazy {
        MutableLiveData<String>().apply {
            postValue("")
        }
    }
    val alertPw:MutableLiveData<String> by lazy {
        MutableLiveData<String>().apply {
            postValue("")
        }
    }

    fun login() {

        val userId = id.value.toString()
        val userPw = pw.value.toString()

        // id 입력칸이 비어있을 경우
        if(userId.isEmpty()) {
            alertId.postValue("아이디를 입력해주세요")
            return
        }
        // 입력한 id가 패턴에 맞지 않을 경우
        else if(!Pattern.matches("^[a-zA-Z0-9]{5,15}\$", userId)) {
            alertId.postValue("아이디는 영문과 숫자를 조합한 5~15글자")
            return
        }

        // pw 입력칸이 비어있을 경우
        if(userPw.isEmpty()) {
            alertPw.postValue("비밀번호를 입력해주세요")
            return
        }

        // 입력받은 id와 pw를 서버에 보내고 응답받기
        viewModelScope.launch(Dispatchers.IO) {
            repository.login(LoginInfo(userId, userPw)).let { response ->
                // 서버 통신 성공
                if(response.isSuccessful) {
                    // 로그인 성공
                    if(response.body()!!.result == "success") {
                        _loginSuccessEvent.postValue(Event(userId))
                        Log.d("tag_login_success", response.body().toString())
                    } else { // 로그인 실패
                        Log.d("tag_login_fail", response.body().toString())
                        alertMsg.postValue(response.body()!!.result)
                    }
                    // 서버 통신 실패
                } else {
                    Log.d("tag_server_fail", "서버 통신 실패: ${response.code()}")
                }
            }
        }
    }
}