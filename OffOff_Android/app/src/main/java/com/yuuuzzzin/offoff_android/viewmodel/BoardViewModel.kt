package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class BoardViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    private val _loading = MutableLiveData<Event<Boolean>>()
    val loading: LiveData<Event<Boolean>> = _loading

    private val _postList = MutableLiveData<List<Post>>()
    val postList: LiveData<List<Post>> get() = _postList

    private val _lastPostId = MutableLiveData<String>()
    val lastPostId: LiveData<String> get() = _lastPostId

    private val _newPostList = MutableLiveData<List<Post>>()
    val newPostList: LiveData<List<Post>> get() = _newPostList

    private val _clearPostList = MutableLiveData<Event<Boolean>>()
    val clearPostList: LiveData<Event<Boolean>> = _clearPostList

    fun getPosts(boardType: String, isRefreshing: Boolean) {

        if (!isRefreshing)
            _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.getPosts(boardType).let { response ->
                if (response.isSuccessful) {

                    if (!isRefreshing)
                        _loading.postValue(Event(false))

                    Log.d("tag_success", "getPosts: ${response.body()}")

                    if (!response.body()!!.postList.isNullOrEmpty()) {
                        _postList.postValue(response.body()!!.postList)
                        _lastPostId.postValue(response.body()!!.lastPostId)
                    }
                } else {
                    Log.d("tag_fail", "getPosts Error: ${response.code()}")
                }
            }
        }
    }

    fun getNextPosts(boardType: String, lastPostId: String) {

        _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.getNextPosts(boardType, lastPostId).let { response ->
                if (response.isSuccessful) {
                    _loading.postValue(Event(false))
                    Log.d("tag_success", "getNextPosts: ${response.body()}")

                    if (!response.body()!!.postList.isNullOrEmpty()) {
                        _postList.postValue(response.body()!!.postList)
                        _lastPostId.postValue(response.body()!!.lastPostId)
                    }
                } else {
                    Log.d("tag_fail", "getNextPosts Error: ${response.code()}")
                }
            }
        }
    }

    fun updatePost(postList: Array<Post>) {
        _newPostList.postValue(postList.toList())
    }
}