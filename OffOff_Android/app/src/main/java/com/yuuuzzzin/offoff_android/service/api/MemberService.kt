package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.LoginInfo
import com.yuuuzzzin.offoff_android.service.models.ResultResponse
import com.yuuuzzzin.offoff_android.service.models.User
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query

/* 회원 가입, 로그인 관련 API 인터페이스 */

interface MemberService {

    /* 로그인 */
    @POST("user/login")
    suspend fun login(
        @Body loginInfo: LoginInfo
    ): Response<ResultResponse>

    /* 회원가입 */
    @POST("user/register")
    suspend fun signup(
        @Body user: User
    ): Response<ResultResponse>

    /* id 중복 확인 */
    @GET("user/register")
    suspend fun checkId(
        @Query("id") id: String
    ): Response<ResultResponse>

    /* 닉네임 중복 확인 */
    @GET("user/register")
    suspend fun checkNickname(
        @Query("nickname") nickname: String
    ): Response<ResultResponse>

    /* 이메일 중복 확인 */
    @GET("user/register")
    suspend fun checkEmail(
        @Query("email") email: String
    ): Response<ResultResponse>

}