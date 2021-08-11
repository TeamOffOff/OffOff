package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

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
    val type: String? = null
)

/* 사용자 부가 정보 */
data class SubInfo(
    @SerializedName("nickname")
    val nickname: String,
    @SerializedName("profileImage")
    val profile: String? = null
)

/* 사용자 활동 */
data class Activity(
    @SerializedName("posts")
    val posts: String? = null,
    @SerializedName("replies")
    val replies: String? = null,
    @SerializedName("likes")
    val likes: String? = null,
    @SerializedName("reports")
    val reports: String? = null,
    @SerializedName("bookmarks")
    val bookmarks: String? = null
)

/* 로그인 정보 */
data class LoginInfo(
    @SerializedName("id")
    val id: String,
    @SerializedName("password")
    val pw: String
)


