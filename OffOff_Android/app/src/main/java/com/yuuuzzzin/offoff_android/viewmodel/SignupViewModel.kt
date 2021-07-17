package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.SignupInfo
import com.yuuuzzzin.offoff_android.service.repository.AuthRepository
import com.yuuuzzzin.offoff_android.util.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import java.util.regex.Pattern
import javax.inject.Inject

@HiltViewModel
class SignupViewModel
@Inject
constructor(
    private val repository: AuthRepository
): ViewModel() {

    val id = MutableLiveData("")
    val pw = MutableLiveData("")
    val checkPw = MutableLiveData("")

    // 회원가입 성공 여부
    private val _signupSuccess = MutableLiveData<Event<String>>()
    val signupSuccess: LiveData<Event<String>> = _signupSuccess

    private val _isIdError = MutableLiveData<Event<String>>()
    val isIdError: LiveData<Event<String>> = _isIdError

    private val _isPwError = MutableLiveData<Event<String>>()
    val isPwError: LiveData<Event<String>> = _isPwError

    private val _isPwCheckError = MutableLiveData<Event<String>>()
    val isPwCheckError: LiveData<Event<String>> = _isPwCheckError

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
        else if(!Pattern.matches("^[a-zA-Z0-9]{5,15}\$", pw.value!!)) {
            _isPwError.value = Event("비밀번호는 영문과 숫자를 조합한 5~15글자")
            checkValue = false
        }
        else {
            for(i in 1..(pw.value!!.length - 3) step(1)) {
                if(id.value!!.contains(pw.value!!.substring(i, i + 3))) {
                    _isPwError.value = Event("아이디와 비밀번호가 4자리 이상 중복됩니다")
                    checkValue = false
                }
            }
        }
        // 비밀번호 확인 값 확인
        if(checkPw.value?.isBlank() == true) {
            _isPwCheckError.value = Event("비밀번호를 한번 더 입력해주세요")
            checkValue = false
        }
        // 비밀번호와 비밀번호 확인 값 비교
        if (pw.value != checkPw.value) {
            _isPwCheckError.value = Event("비밀번호가 일치하지 않습니다")
            checkValue = false
        }

        return checkValue
    }

    // 회원가입 요청
    fun signup() {
        if (!checkInfo()) return

        val userId = id.value ?: return
        val userPw = pw.value ?: return

        // 입력받은 id와 pw를 서버에 보내고 응답받기
        viewModelScope.launch() {
            repository.signup(SignupInfo(userId, userPw)).let { response ->
                // 서버 통신 성공
                if(response.isSuccessful) {
                    // 회원가입 성공
                    if(response.body()!!.result == "success") {
                        _signupSuccess.postValue(Event(userId))
                        Log.d("tag_signup_success", userId+userPw+response.body().toString())
                    } else { // 회원가입 실패
                        Log.d("tag_signup_fail", response.body().toString())
                    }
                    // 서버 통신 실패
                } else {
                    Log.d("tag_server_fail", "서버 통신 실패: ${response.code()}")
                }
            }
        }
    }
}