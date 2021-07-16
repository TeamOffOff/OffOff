package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.AuthResponse
import com.yuuuzzzin.offoff_android.service.models.LoginInfo
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST

interface AuthService {

    @POST("signin")
    suspend fun login(
        @Body loginInfo: LoginInfo
    ): Response<AuthResponse>
}