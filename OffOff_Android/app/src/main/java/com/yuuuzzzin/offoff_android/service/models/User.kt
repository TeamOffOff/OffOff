package com.yuuuzzzin.offoff_android.service.models

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

data class User( // *** 수정 필요
    @SerializedName("id")
    val id: String
)

@Parcelize
data class LoginInfo(
    @SerializedName("id")
    val id: String,
    @SerializedName("password")
    val pw: String
) : Parcelable


