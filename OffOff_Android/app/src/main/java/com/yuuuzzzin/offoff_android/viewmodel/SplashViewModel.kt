package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.*
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.repository.MemberRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SplashViewModel
@Inject
constructor(
    private val repository: MemberRepository
) : ViewModel() {

    // 토큰의 유효성 여부
    private val _tokenVerified = MutableLiveData<Boolean>()
    val tokenVerified: LiveData<Boolean> = _tokenVerified

    // 1초 뒤 값이 들어오는 LiveData
    private val _time = MutableLiveData<Boolean>()
    val time: LiveData<Boolean> = _time

    // 자동 로그인
    private val _autoLogin = combine(
        tokenVerified.asFlow(),
        time.asFlow(),
    ) { token, time ->
        token && time
    }.onStart { emit(false) }.asLiveData()
    val autoLogin: LiveData<Boolean> get() = _autoLogin

    // 로그인 화면으로 이동 필요
    private val _moveLogin = combine(
        tokenVerified.asFlow(),
        time.asFlow(),
    ) { token, time ->
        !token && time
    }.onStart { emit(false) }.asLiveData()
    val moveLogin: LiveData<Boolean> get() = _moveLogin

    init {
        checkLogin()
    }

    private fun checkLogin() {

        // 1초 후 time 값 true
        viewModelScope.launch() {
            delay(1000)
            _time.postValue(true)
        }

        // 토큰 검사
        viewModelScope.launch(Dispatchers.IO) {
            val token = OffoffApplication.pref.token // 토큰

            if (!token.isNullOrEmpty()) { // 저장된 토큰이 있는 경우
                repository.getUserInfo(token).let { response ->
                    if (response.isSuccessful) { // 토큰이 유효한 경우
                        _tokenVerified.postValue(true)
                        Log.d("tag_success", "getUserInfo: ${response.body()}")
                    } else { // 토큰이 유효하지 않은 경우
                        _tokenVerified.postValue(false)
                        Log.d("tag_fail", "getUserInfo Error: ${response.code()}")
                    }
                }
            } else { // 저장된 토큰이 없는 경우
                _tokenVerified.postValue(false)
            }
        }
    }
}