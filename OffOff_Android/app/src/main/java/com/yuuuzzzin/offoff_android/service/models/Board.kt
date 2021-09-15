package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName
import com.yuuuzzzin.offoff_android.utils.Identifiable

// 게시판 관련 객체 모델

/* 게시판 리스트 */
data class BoardList(
    @SerializedName("boardList")
    val boardList: List<Board>
)

/* 게시판 */
data class Board(
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("name")
    val name: String,
    @SerializedName("icon")
    val icon: String,
    @SerializedName("newPost")
    val newPost: String
) : Identifiable {
    override val identifier: Any
        get() = boardType
}