package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.PostList
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Header

/* 사용자 활동 관련 API 인터페이스 */

interface ActivityService {

    /* 좋아요한 게시물 목록 불러오기 */
    @GET("user/likes")
    suspend fun getMyLikeList(
        @Header("Authorization") auth: String,
    ): Response<PostList>

    /*  작성한 게시물 목록 불러오기 */
    @GET("user/posts")
    suspend fun getMyPostList(
        @Header("Authorization") auth: String,
    ): Response<PostList>

    /* 신고한 게시물 목록 불러오기 */
    @GET("user/reports")
    suspend fun getMyReportList(
        @Header("Authorization") auth: String,
    ): Response<PostList>

    /* 스크랩한 게시물 목록 불러오기 */
    @GET("user/bookmarks")
    suspend fun getMyBookmarkList(
        @Header("Authorization") auth: String,
    ): Response<PostList>

    /* 댓글 단 게시물 목록 불러오기 */
    @GET("user/bookmarks")
    suspend fun getMyCommentPostList(
        @Header("Authorization") auth: String,
    ): Response<PostList>

}