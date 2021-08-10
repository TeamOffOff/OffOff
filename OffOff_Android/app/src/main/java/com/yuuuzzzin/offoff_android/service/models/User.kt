package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

/* 사용자 */
data class User(
    @SerializedName("id")
    val id: String,
    @SerializedName("password")
    val password: String,
    @SerializedName("information")
    val info: Info,
    @SerializedName("subinfo")
    val subInfo: SubInfo,
    @SerializedName("activity")
    val activity: com.yuuuzzzin.offoff_android.service.models.Activity,
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
    val type: String?
)

/* 사용자 부가 정보 */
data class SubInfo(
    @SerializedName("nickname")
    val nickname: String,
    @SerializedName("profile_image")
    val profile: String?
)

/* 사용자 활동 */
data class Activity(
    @SerializedName("posts")
    val posts: String?,
    @SerializedName("comments")
    val comments: String?,
    @SerializedName("likes")
    val likes: String?,
    @SerializedName("bookmarks")
    val bookmarks: String?
)

/* 로그인 정보 */
data class LoginInfo(
    @SerializedName("id")
    val id: String,
    @SerializedName("password")
    val pw: String
)


