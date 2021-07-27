package com.yuuuzzzin.offoff_android.service.api

import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.models.PostList
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Path

/* 게시판 API 인터페이스 */

interface BoardService {

    /* 특정 게시판의 게시물들을 불러오기 */
    @GET("postlist/free")
    suspend fun getPosts(): Response<PostList>

    /* 해당 id의 게시물 불러오기 */
    @GET("GetPosts/{id}")
    suspend fun getPost(
        @Path("id") postId: String
    ): Response<Post>
}