package com.yuuuzzzin.offoff_android.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.yuuuzzzin.offoff_android.service.repository.MemberRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class ChangePwViewModel
@Inject
constructor(
    private val repository: MemberRepository
) : ViewModel() {
    val pw: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }
    val pwConfirm: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }

//    fun validatePw() {
//        if (!SignupUtils.validate(pw, SignupUtils.PW_REGEX)) {
//            _isPwVerified.postValue(SignupUtils.PW_ERROR)
//        } else {
//            _isPwVerified.postValue("")
//        }
//    }
//
//    fun validatePwConfirm() {
//        if (pwConfirm.get().isNullOrEmpty() || pw.get() != pwConfirm.get()) {
//            _isPwConfirmVerified.postValue(SignupUtils.PW_CONFIRM_ERROR)
//        } else {
//            _isPwConfirmVerified.postValue("")
//            userPw = pw.value!!
//        }
//    }
}
