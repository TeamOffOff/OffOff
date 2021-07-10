package com.yuuuzzzin.offoff_android.service.model

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

data class PostList (
    val post: ArrayList<Post>
)

data class Post(
    @SerializedName("content_id")
    val content_id: String,
    @SerializedName("metadata")
    val metadata: Metadata,
    @SerializedName("contents")
    val contents: Contents
)

@Parcelize
data class Metadata(
    @SerializedName("author")
    val author: String = "작성자",
    @SerializedName("title")
    val title: String = "제목",
    @SerializedName("date")
    val date: String = "0000 00/00",
    @SerializedName("board_typ")
    val board_typ: String = "게시판",
    @SerializedName("preview")
    val preview: String = "미리보기",
    @SerializedName("likes")
    val likes: Int = 0,
    @SerializedName("view_count")
    val view_count: Int = 0,
    @SerializedName("report_count")
    val report_count: Int = 0,
    @SerializedName("reply_count")
    val reply_count: Int = 0
) : Parcelable

@Parcelize
data class Contents(
    @SerializedName("content")
    val content: String
) : Parcelable

data class PostPreviewList (
    val postPreview: ArrayList<PostPreview>
)

data class PostPreview(
    @SerializedName("content_id")
    val content_id: String,
    @SerializedName("metadata")
    val metadataPreview: MetadataPreview,
    @SerializedName("contents")
    val contents: Contents
)

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
)
