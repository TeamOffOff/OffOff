package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

data class AuthResponse(
    @SerializedName("Authorization")
    val auth: String,
    @SerializedName("message")
    val message: String
)
