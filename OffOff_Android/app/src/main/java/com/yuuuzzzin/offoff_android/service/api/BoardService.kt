package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.BoardList
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.models.PostList
import com.yuuuzzzin.offoff_android.service.models.PostSend
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
        @Query("postId") post_id: String,
        @Query("boardType") board_type: String
    ): Response<Post>

    /* 게시물 작성 */
    @POST("post")
    suspend fun writePost(
        @Body post: PostSend
    ): Response<Post>
}