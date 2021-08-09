package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

data class ResultResponse(
    @SerializedName("query_status")
    val queryStatus: String,
    @SerializedName("message")
    val message: String
)
