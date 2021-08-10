package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

data class ResultResponse(
    @SerializedName("Authorization")
    val auth: String,
    @SerializedName("queryStatus")
    val queryStatus: String,
    @SerializedName("message")
    val message: String
)
