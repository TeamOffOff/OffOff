package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

// 게시판 객체 모델
data class Board(
    var title: String = "",
    var icon: Int = 0
)

data class asd(
    @SerializedName("id")
    val id: String,
    @SerializedName("metadata")
    val metadata: Metadata,
    @SerializedName("contents")
    val contents: Contents
)
