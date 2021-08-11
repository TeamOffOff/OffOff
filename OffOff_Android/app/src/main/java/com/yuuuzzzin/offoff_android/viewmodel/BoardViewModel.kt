package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class BoardViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    private val _postList = ArrayList<Post>()
    val postList: MutableLiveData<ArrayList<Post>> by lazy {
        MutableLiveData<ArrayList<Post>>()
    }

    fun getPosts(boardType: String) = viewModelScope.launch {
        repository.getPosts(boardType).let { response ->
            if (response.isSuccessful) {
                Log.d("tag_success", "getPosts: ${response.body()}")
                if (response.body()!!.postList != null) {
                    for (post in response.body()!!.postList) {
                        _postList.add(post)
                    }
                    postList.postValue(_postList)
                }

            } else {
                Log.d("tag_fail", "getPosts Error: ${response.code()}")
            }
        }
    }
}