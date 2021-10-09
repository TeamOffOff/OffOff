package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.ActivityItem
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.models.PostSend
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PostViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    lateinit var boardType: String
    lateinit var postId: String

    private val _response = MutableLiveData<Post>()
    val response: LiveData<Post> get() = _response

    private val _author = MutableLiveData<String>()
    val author: LiveData<String> get() = _author

    private val _likes = MutableLiveData<Int>()
    val likes: LiveData<Int> get() = _likes

    // 로그인 실패 메시지
    private val _alreadyLike = MutableLiveData<Event<String>>()
    val alreadyLike: LiveData<Event<String>> = _alreadyLike

    fun getPost(postId: String, boardType: String) = viewModelScope.launch(Dispatchers.IO) {

        repository.getPost(OffoffApplication.pref.token.toString(), postId, boardType)
            .let { response ->
                if (response.isSuccessful) {
                    _response.postValue(response.body())
                    _author.postValue(response.body()!!.author.id)
                    _likes.postValue(response.body()!!.likes.size)
                    Log.d("tag_success", response.body().toString())
                } else {
                    Log.d("tag_fail", "getPost Error: ${response.code()}")
                }
            }

    }

    fun deletePost(postId: String, boardType: String) {

        val postSend = PostSend(
            id = postId,
            boardType = boardType,
            author = OffoffApplication.user.id,
        )

        viewModelScope.launch(Dispatchers.IO) {

            repository.deletePost(OffoffApplication.pref.token.toString(), postSend)
                .let { response ->
                    if (response.isSuccessful) {
                        Log.d("tag_success", response.body().toString())
                    } else {
                        Log.d("tag_fail", "deletePost Error: ${response.code()}")
                    }
                }

        }
    }

    fun likePost() {

        val activityItem = ActivityItem(
            id = postId,
            boardType = boardType,
            activity = "likes"
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.likePost(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        when (response.code()) {
                            OK -> {
                                _response.postValue(response.body())
                                Log.d("tag_success", response.body().toString())
                            }
                            CREATED ->
                                _alreadyLike.postValue(Event("이미 좋아요한 게시글입니다."))                        }
                    } else {
                        Log.d("tag_fail", "likePost Error: ${response.code()}")
                    }
                }
        }
    }

    companion object {
        const val OK = 200
        const val CREATED = 201
    }
}