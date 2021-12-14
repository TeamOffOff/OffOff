package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

data class AuthResponse(
    @SerializedName("accessToken")
    val accessToken: String,
    @SerializedName("queryStatus")
    val queryStatus: String
)
