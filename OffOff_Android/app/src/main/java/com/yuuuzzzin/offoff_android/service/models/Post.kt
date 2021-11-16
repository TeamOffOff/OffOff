package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName
import java.io.Serializable

// 게시물 관련 객체 모델

/* 게시물 리스트 */
data class PostList(
    @SerializedName("lastPostId")
    val lastPostId: String,
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
    @SerializedName("title")
    val title: String,
    @SerializedName("content")
    val content: String,
    @SerializedName("image")
    val image: List<Image>? = emptyList(),
    @SerializedName("date")
    val date: String,
    @SerializedName("views")
    val views: Int? = 0,
    @SerializedName("replyCount")
    var replyCount: Int? = 0,
    @SerializedName("likes")
    val likes: List<String>? = emptyList(),
    @SerializedName("reports")
    val reports: List<Any>? = emptyList(),
    @SerializedName("bookmarks")
    val bookmarks: List<Any>? = emptyList(),
) : Serializable

/* 보내는 게시물 */
data class PostSend(
    @SerializedName("_id")
    val id: String? = null,
    @SerializedName("boardType")
    val boardType: String,
    @SerializedName("author")
    val author: String,
    @SerializedName("title")
    val title: String? = null,
    @SerializedName("content")
    val content: String? = null,
    @SerializedName("image")
    val image: List<Image>? = emptyList(),
)

/* 작성자 */
data class Author(
    @SerializedName("_id")
    val id: String,
    @SerializedName("nickname")
    val nickname: String? = null,
    @SerializedName("profileImage")
    val profileImage: List<Image>? = emptyList(),
    @SerializedName("type")
    val type: String? = null
) : Serializable

/* 이미지 */
data class Image(
    @SerializedName("key")
    val key: String?,
    @SerializedName("body")
    val body: String?
) : Serializable