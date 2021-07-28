package com.yuuuzzzin.offoff_android.service.models

import com.google.gson.annotations.SerializedName

data class Post(
    @SerializedName("board_type")
    val board_type: String,
    @SerializedName("Author")
    val author: String,
    @SerializedName("Date")
    val date: String,
    @SerializedName("Title")
    val title: String,
    @SerializedName("Content")
    val content: String,
    @SerializedName("image")
    val image: String,
    @SerializedName("Likes")
    val likes: Int,
    @SerializedName("view_count")
    val view_count: Int,
    @SerializedName("report_count")
    val report_count: Int,
    @SerializedName("reply_count")
    val reply_count: Int
)

data class PostList(
    @SerializedName("last_content_id")
    val last_id: String,
    @SerializedName("post_list")
    val post_list: List<PostPreview>
)

data class PostPreview(
    @SerializedName("_id")
    val id: String,
    @SerializedName("board_type")
    val board_type: String,
    @SerializedName("Author")
    val author: String,
    @SerializedName("Date")
    val date: String,
    @SerializedName("Title")
    val title: String,
    @SerializedName("Content")
    val content: String,
    @SerializedName("Likes")
    val likes: Int,
    @SerializedName("reply_count")
    val reply_count: Int
)