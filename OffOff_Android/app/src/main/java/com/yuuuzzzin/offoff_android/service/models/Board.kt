package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName
import com.yuuuzzzin.offoff_android.utils.Identifiable

// 게시판 관련 객체 모델

data class BoardList(
    @SerializedName("board")
    val board_list: List<Board>
)

data class Board(
    @SerializedName("board_type")
    val board_type: String,
    @SerializedName("name")
    val name: String,
    @SerializedName("icon")
    val icon: String
) : Identifiable {
    override val identifier: Any
        get() = board_type
}