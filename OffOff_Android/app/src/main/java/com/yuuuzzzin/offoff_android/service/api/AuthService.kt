package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.AuthResponse
import com.yuuuzzzin.offoff_android.service.models.ResultResponse
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.HTTP
import retrofit2.http.Header

/* 토큰 관련 API 인터페이스 */

interface AuthService {

    /* 토큰 재발급 */
    @GET("token")
    suspend fun getUserInfo(
        @Header("Authorization") auth: String
    ): Response<AuthResponse>

    /* 토큰 삭제 */
    @HTTP(method = "DELETE", path = "refresh", hasBody = true)
    suspend fun deleteToken(
        @Header("Authorization") auth: String,
    ): Response<ResultResponse>
}