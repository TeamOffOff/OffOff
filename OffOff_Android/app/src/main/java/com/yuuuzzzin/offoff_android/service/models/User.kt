package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

/* 로그인 정보 */
data class LoginInfo(
    @SerializedName("_id")
    val id: String,
    @SerializedName("password")
    val pw: String
)

/* 로그인 응답 */
data class LoginResponse(
    @SerializedName("accessToken")
    val accessToken: String,
    @SerializedName("refreshToken")
    val refreshToken: String,
    @SerializedName("user")
    val user: User,
)

/* 사용자 정보 객체 */
data class UserInfo(
    @SerializedName("user")
    val user: User
)

/* 사용자 */
data class User(
    @SerializedName("_id")
    val id: String,
    @SerializedName("password")
    val password: String,
    @SerializedName("information")
    val info: Info,
    @SerializedName("subInformation")
    val subInfo: SubInfo,
    @SerializedName("activity")
    val activity: Activity,
)

/* 사용자 정보 */
data class Info(
    @SerializedName("name")
    val name: String,
    @SerializedName("email")
    val email: String,
    @SerializedName("birth")
    val birth: String,
    @SerializedName("type")
    val type: String? = "student"
)

/* 사용자 부가 정보 */
data class SubInfo(
    @SerializedName("nickname")
    val nickname: String,
    @SerializedName("profileImage")
    val profile: List<Image>? = emptyList()
)

/* 사용자 활동 정보 */
data class Activity(
    @SerializedName("posts")
    val posts: List<Any>? = emptyList(),
    @SerializedName("replies")
    val replies: List<Any>? = emptyList(),
    @SerializedName("likes")
    val likes: List<Any>? = emptyList(),
    @SerializedName("reports")
    val reports: List<Any>? = emptyList(),
    @SerializedName("bookmarks")
    val bookmarks: List<Any>? = emptyList()
)