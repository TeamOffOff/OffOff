package com.yuuuzzzin.offoff_android.service.models

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

data class Post(
    @SerializedName("id")
    val id: String,
    @SerializedName("metadata")
    val metadata: Metadata,
    @SerializedName("contents")
    val contents: Contents
)

@Parcelize
data class Metadata(
    @SerializedName("author")
    val author: String,
    @SerializedName("title")
    val title: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("board_type")
    val board_type: String,
    @SerializedName("preview")
    val preview: String,
    @SerializedName("likes")
    val likes: Int,
    @SerializedName("view_count")
    val view_count: Int,
    @SerializedName("report_count")
    val report_count: Int,
    @SerializedName("reply_count")
    val reply_count: Int
) : Parcelable

data class PostList(
    @SerializedName("last_content_id")
    val last_id: String,
    @SerializedName("post_list")
    val post_list: List<PostPreview>
)

data class PostPreview(
    @SerializedName("_id")
    val id: String,
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

@Parcelize
data class MetadataPreview(
    @SerializedName("author")
    val author: String,
    @SerializedName("title")
    val title: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("likes")
    val likes: Int,
    @SerializedName("reply_count")
    val reply_count: Int
) : Parcelable

@Parcelize
data class Contents(
    @SerializedName("content")
    val content: String
) : Parcelable