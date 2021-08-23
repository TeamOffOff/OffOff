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
    val id: String = "",
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("author")
    val author: Author,
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
    val author: Author,
    @SerializedName("user")
    val user: String? = null,
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

/* 작성자 */
data class Author(
    @SerializedName("_id")
    val id: String,
    @SerializedName("nickname")
    val nickname: String? = null,
    @SerializedName("type")
    val type: String? = null,
    @SerializedName("profileImage")
    val profile: String? = null
)