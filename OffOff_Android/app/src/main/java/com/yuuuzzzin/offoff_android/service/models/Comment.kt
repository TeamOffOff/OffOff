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
    @SerializedName("parent")
    val parent: Parent,
    @SerializedName("author")
    val author: Author,
    @SerializedName("content")
    val content: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("likes")
    val likes: Int,
    @SerializedName("subReplies")
    val subComment: List<SubComment>
) : Identifiable {
    override val identifier: Any
        get() = id
}

/* 부모 */
data class Parent(
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("postId")
    val postId: String,
    @SerializedName("replyId")
    val commentId: String
)

/* 대댓글 */
data class SubComment(
    @SerializedName("parent")
    val parent: Parent,
    @SerializedName("author")
    val author: Author,
    @SerializedName("content")
    val content: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("likes")
    val likes: Int
)

/* 보내는 댓글 */
data class CommentSend(
    @SerializedName("_id")
    val id: String? = null,
    @SerializedName("parent")
    val parent: Parent,
    @SerializedName("author")
    val author: Author,
    @SerializedName("user")
    val user: String,
    @SerializedName("content")
    val content: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("likes")
    val likes: Int,
)