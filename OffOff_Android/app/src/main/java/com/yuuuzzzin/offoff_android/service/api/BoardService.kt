package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.*
import retrofit2.Response
import retrofit2.http.*

/* 게시판 관련 API 인터페이스 */

interface BoardService {

    /* 게시판 리스트 불러오기 */
    @GET("boardlist")
    suspend fun getBoardList(): Response<BoardList>

    /* 특정 게시판의 게시물들을 불러오기 */
    @GET("postlist/{boardType}")
    suspend fun getPosts(
        @Path("boardType") board_type: String
    ): Response<PostList>

    /* 해당 id의 게시물 불러오기 */
    @GET("post")
    suspend fun getPost(
        @Header("Authorization") auth: String,
        @Query("postId") post_id: String,
        @Query("boardType") board_type: String
    ): Response<Post>

    /* 게시물 작성 */
    @POST("post")
    suspend fun writePost(
        @Header("Authorization") auth: String,
        @Body post: PostSend
    ): Response<Post>

    /* 게시물 수정 */
    @PUT("post")
    suspend fun editPost(
        @Header("Authorization") auth: String,
        @Body post: PostSend
    ): Response<Post>

    /* 게시물 삭제 */
    @HTTP(method = "DELETE", path = "post", hasBody = true)
    suspend fun deletePost(
        @Header("Authorization") auth: String,
        @Body post: PostSend
    ): Response<ResultResponse>

    /* 게시물 좋아요 */
    @PUT("post")
    suspend fun likePost(
        @Header("Authorization") auth: String,
        @Body activityItem: ActivityItem
    ): Response<Post>

    /* 댓글 조회 */
    @GET("reply")
    suspend fun getComments(
        @Header("Authorization") auth: String,
        @Query("postId") postId: String,
        @Query("boardType") boardType: String
    ): Response<CommentList>

    /* 댓글 작성 */
    @POST("reply")
    suspend fun writeComment(
        @Header("Authorization") auth: String,
        @Body comment: CommentSend
    ): Response<CommentList>

    /* 댓글 삭제 */
    @HTTP(method = "DELETE", path = "reply", hasBody = true)
    suspend fun deleteComment(
        @Header("Authorization") auth: String,
        @Body comment: CommentSend
    ): Response<CommentList>

    /* 댓글 좋아요 */
    @PUT("reply")
    suspend fun likeComment(
        @Header("Authorization") auth: String,
        @Body activityItem: ActivityItem
    ): Response<ResultResponse>

}