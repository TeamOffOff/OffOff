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
    @SerializedName("postId")
    val postId: String,
    @SerializedName("parentReplyId")
    val parentReplyId: String? = null,
    @SerializedName("content")
    val content: String,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("author")
    val author: Author,
    @SerializedName("likes")
    val likes: MutableList<String>? = mutableListOf(),
    @SerializedName("childrenReplies")
    val childrenReplies: List<Reply>? = emptyList()
) : Identifiable {
    override val identifier: Any
        get() = id
}

/* 대댓글 */
data class Reply(
    @SerializedName("_id")
    val id: String? = null,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("postId")
    val postId: String,
    @SerializedName("parentReplyId")
    val parentReplyId: String? = null,
    @SerializedName("content")
    val content: String? = null,
    @SerializedName("date")
    val date: String? = null,
    @SerializedName("author")
    val author: Author? = null,
    @SerializedName("likes")
    val likes: MutableList<String>? = mutableListOf()
)

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
    @SerializedName("isChildReply")
    val isChildReply: Boolean? = null,
    @SerializedName("content")
    val content: String? = null,
    @SerializedName("author")
    val author: String? = null,
    @SerializedName("likes")
    val likes: List<String> = emptyList()
)

/* 보내는 대댓글 */
data class ReplySend(
    @SerializedName("_id")
    val id: String? = null,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("postId")
    val postId: String,
    @SerializedName("parentReplyId")
    val parentReplyId: String? = null,
    @SerializedName("author")
    val author: String? = null
)