package com.yuuuzzzin.offoff_android.service.models

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

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

data class SubInfo(
    @SerializedName("nickname")
    val nickname: String,
    @SerializedName("profile_image")
    val profile: String?
)

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

@Parcelize
data class LoginInfo(
    @SerializedName("id")
    val id: String,
    @SerializedName("password")
    val pw: String
) : Parcelable


