package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

data class AuthResponse(

    @SerializedName("query_status")
    val result: String
)
