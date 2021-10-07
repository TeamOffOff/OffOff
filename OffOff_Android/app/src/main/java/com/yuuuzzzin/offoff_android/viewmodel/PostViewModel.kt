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

    private val _response = MutableLiveData<Post>()
    val response: LiveData<Post> get() = _response

    private val _author = MutableLiveData<String>()
    val author: LiveData<String> get() = _author

    fun getPost(postId: String, boardType: String) = viewModelScope.launch(Dispatchers.IO) {

        repository.getPost(OffoffApplication.pref.token.toString(), postId, boardType)
            .let { response ->
                if (response.isSuccessful) {
                    _response.postValue(response.body())
                    _author.postValue(response.body()!!.author.id)
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

    fun like(boardType: String, postId: String) {

        val activityItem = ActivityItem(
            id = postId,
            boardType = boardType,
            activity = "likes"
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.like(OffoffApplication.pref.token.toString(), activityItem).let { response ->
                if (response.isSuccessful) {
                    _response.postValue(response.body())
                    Log.d("tag_success", response.body().toString())
                } else {
                    Log.d("tag_fail", "like Error: ${response.code()}")
                }
            }
        }
    }
}