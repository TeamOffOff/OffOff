package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.*
import retrofit2.Response
import retrofit2.http.*

/* 회원 가입, 로그인 관련 API 인터페이스 */

interface MemberService {

    /* 로그인 */
    @POST("user/login")
    suspend fun login(
        @Body loginInfo: LoginInfo
    ): Response<LoginResponse>

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

    /* 회원정보 조회 */
    @GET("user/login")
    suspend fun getUserInfo(
        @Header("Authorization") auth: String
    ): Response<UserInfo>

    /* 회원정보 수정 */
    @PUT("user/register")
    suspend fun editProfile(
        @Header("Authorization") auth: String,
        @Body userInfo: UserInfo
    ): Response<UserInfo>

    /* 비밀번호 변경 */
    @PUT("user/register")
    suspend fun changePw(
        @Header("Authorization") auth: String,
        @Body password: String
    ): Response<ResultResponse>

    /* 회원 탈퇴 */
    @HTTP(method = "DELETE", path = "user/register", hasBody = true)
    suspend fun unregister(
        @Header("Authorization") auth: String,
    ): Response<ResultResponse>

}