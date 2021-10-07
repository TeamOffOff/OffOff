package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

data class LoginResponse(
    @SerializedName("accessToken")
    val accessToken: String,
    @SerializedName("refreshToken")
    val refreshToken: String,
    @SerializedName("user")
    val user: User,
)

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
    val profile: String? = null
)

/* 사용자 활동 */
data class Activity(
    @SerializedName("posts")
    val posts: List<PostItem> ?= emptyList(),
    @SerializedName("replies")
    val replies: List<ReplyItem>?= emptyList(),
    @SerializedName("likes")
    val likes: List<LikeItem>?= emptyList(),
    @SerializedName("reports")
    val reports: List<Report>?= emptyList(),
    @SerializedName("bookmarks")
    val bookmarks: List<Bookmark>?= emptyList()
)

/* 로그인 정보 */
data class LoginInfo(
    @SerializedName("_id")
    val id: String,
    @SerializedName("password")
    val pw: String
)

data class PostItem(
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("postId")
    val postId: String,
    @SerializedName("replyId")
    val replyId: String
)

/* 임시 data class */

data class ReplyItem(
    @SerializedName("_id")
    val id: String
)

data class LikeItem(
    @SerializedName("_id")
    val id: String
)

data class Report(
    @SerializedName("_id")
    val id: String
)

data class Bookmark(
    @SerializedName("_id")
    val id: String
)

