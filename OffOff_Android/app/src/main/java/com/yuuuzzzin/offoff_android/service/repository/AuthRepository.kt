package com.yuuuzzzin.offoff_android.service.repository

import com.yuuuzzzin.offoff_android.service.api.AuthService
import com.yuuuzzzin.offoff_android.service.models.AuthResponse
import com.yuuuzzzin.offoff_android.service.models.LoginInfo
import retrofit2.Response
import javax.inject.Inject

/* 권한 응답 Repository */

class AuthRepository

@Inject
constructor(private val authService: AuthService) {

    suspend fun login(loginInfo: LoginInfo): Response<AuthResponse> =
        authService.login(loginInfo)
}
