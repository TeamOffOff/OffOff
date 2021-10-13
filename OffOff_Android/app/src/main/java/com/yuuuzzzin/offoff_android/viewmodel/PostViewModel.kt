package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.*
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
    val content = MutableLiveData("")

    private val _response = MutableLiveData<Post>()
    val response: LiveData<Post> get() = _response

    private val _commentList = MutableLiveData<List<Comment>>()
    val commentList: LiveData<List<Comment>> get() = _commentList

    private val _author = MutableLiveData<String>()
    val author: LiveData<String> get() = _author

    private val _likes = MutableLiveData<Int>()
    val likes: LiveData<Int> get() = _likes

    // 이미 좋아요
    private val _alreadyLike = MutableLiveData<Event<String>>()
    val alreadyLike: LiveData<Event<String>> = _alreadyLike

    // 댓글
    private val _successEvent = MutableLiveData<Event<String>>()
    val successEvent: LiveData<Event<String>> = _successEvent

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

    fun getComments(postId: String, boardType: String) = viewModelScope.launch(Dispatchers.IO) {

        repository.getComments(OffoffApplication.pref.token.toString(), postId, boardType)
            .let { response ->
                if (response.isSuccessful) {
                    Log.d("tag_success", "getComments: ${response.body()}")
                    if (!response.body()!!.commentList.isNullOrEmpty()) {
                        _commentList.postValue(response.body()!!.commentList)
                        // count = response.body()!!.commentList.size
                    }
                } else {
                    Log.d("tag_fail", "getComments Error: ${response.code()}")
                }
            }

    }

    fun writeComment(postId: String, boardType: String) {
        //if (!check()) return

        val comment = CommentSend(
            boardType = boardType,
            postId = postId,
            parentReplyId = null,
            content = content.value!!,
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.writeComment(OffoffApplication.pref.token!!, comment).let { response ->
                if (response.isSuccessful) {
                    //_successEvent.postValue(Event(response.body()!!.commentList))
                    Log.d("tag_success", "writePost: ${response.body()}")
                } else {
                    Log.d("tag_fail", "writePost Error: ${response.code()}")
                }
            }
        }
    }

    companion object {
        const val OK = 200
        const val CREATED = 201
    }
}