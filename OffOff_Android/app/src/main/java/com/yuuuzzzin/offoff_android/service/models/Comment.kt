package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName
import com.yuuuzzzin.offoff_android.utils.Identifiable

/* 댓글 리스트 */
data class CommentList(
    @SerializedName("replyList")
    val commentList: List<Comment>
)

/* 댓글 */
data class Comment(
    @SerializedName("_id")
    val id: String,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("postId")
    val postId: String,
    @SerializedName("parentReplyId")
    val parentReplyId: String,
    @SerializedName("content")
    val content: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("author")
    val author: Author,
    @SerializedName("likes")
    val likes:List<String> = emptyList()
) : Identifiable {
    override val identifier: Any
        get() = id
}

/* 보내는 댓글 */
data class CommentSend(
    @SerializedName("_id")
    val id: String? = null,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("postId")
    val postId: String,
    @SerializedName("parentReplyId")
    val parentReplyId: String? = null,
    @SerializedName("content")
    val content: String,
)