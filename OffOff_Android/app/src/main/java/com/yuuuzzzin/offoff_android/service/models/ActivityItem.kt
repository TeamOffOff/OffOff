package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

/* 게시물 좋아요, 북마크, 신고 */
data class ActivityItem(
    @SerializedName("_id")
    val id: String,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("activity")
    val activity: String
)