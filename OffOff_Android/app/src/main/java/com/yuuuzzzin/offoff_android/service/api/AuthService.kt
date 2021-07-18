package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.AuthResponse
import com.yuuuzzzin.offoff_android.service.models.LoginInfo
import com.yuuuzzzin.offoff_android.service.models.SignupInfo
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST

interface AuthService {

    @POST("signin")
    suspend fun login(
        @Body loginInfo: LoginInfo
    ): Response<AuthResponse>

    @POST("signup")
    suspend fun signup(
        @Body signupInfo: SignupInfo
    ): Response<AuthResponse>
}