package com.yuuuzzzin.offoff_android.service

import com.yuuuzzzin.offoff_android.service.model.Post
import com.yuuuzzzin.offoff_android.service.model.PostPreview
import retrofit2.Call
import retrofit2.http.GET

interface PostService {
    @GET("GetPosts")
    fun getPosts(): Call<List<Post>>
}