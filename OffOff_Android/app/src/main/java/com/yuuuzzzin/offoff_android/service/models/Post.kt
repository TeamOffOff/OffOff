package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName
import com.yuuuzzzin.offoff_android.utils.Identifiable

// 게시물 관련 객체 모델

/* 게시물 리스트 */
data class PostList(
    @SerializedName("lastPostId")
    val lastId: String,
    @SerializedName("postList")
    val postList: List<Post>
)

/* 게시물 */
data class Post(
    @SerializedName("_id")
    val id: String,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("author")
    val author: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("title")
    val title: String,
    @SerializedName("content")
    val content: String,
    @SerializedName("image")
    val image: String?,
    @SerializedName("likes")
    val likes: Int?,
    @SerializedName("viewCount")
    val viewCount: Int?,
    @SerializedName("reportCount")
    val reportCount: Int,
    @SerializedName("replyCount")
    val replyCount: Int?
) : Identifiable {
    override val identifier: Any
        get() = id
}

/* 보내는 게시물 */
data class PostSend(
    @SerializedName("_id")
    val id: String? = null,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("author")
    val author: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("title")
    val title: String,
    @SerializedName("content")
    val content: String,
    @SerializedName("image")
    val image: String? = null,
    @SerializedName("likes")
    val likes: Int? = 0,
    @SerializedName("viewCount")
    val viewCount: Int? = 0,
    @SerializedName("reportCount")
    val reportCount: Int? = 0,
    @SerializedName("replyCount")
    val replyCount: Int? = 0
)

/* 댓글 리스트 */
data class ReplyList(
    @SerializedName("replyList")
    val replyList: List<Reply>
)

/* 댓글 */
data class Reply(
    @SerializedName("_id")
    val id: String,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("postId")
    val postId: String,
    @SerializedName("reply")
    val replyDetail: List<ReplyDetail>,
    @SerializedName("subReply")
    val subReply: List<SubReply>
) : Identifiable {
    override val identifier: Any
        get() = id
}

/* 댓글 상세 */
data class ReplyDetail(
    @SerializedName("author")
    val id: String,
    @SerializedName("content")
    val content: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("reply")
    val likes: Int
)

/* 대댓글 */
data class SubReply(
    @SerializedName("author")
    val id: String,
    @SerializedName("content")
    val content: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("reply")
    val likes: Int
)