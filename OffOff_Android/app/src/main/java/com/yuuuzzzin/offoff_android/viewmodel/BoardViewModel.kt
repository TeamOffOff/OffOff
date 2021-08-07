package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.models.PostList
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
    val postList: MutableLiveData<ArrayList<Post>> by lazy{
        MutableLiveData<ArrayList<Post>>()
    }

    private val _response = MutableLiveData<PostList>()
    val response: LiveData<PostList>
        get() = _response

//    init {
//        getPosts()
//    }

    fun getPosts(boardType: String) = viewModelScope.launch {
        repository.getPosts(boardType).let { response ->
            if (response.isSuccessful) {
                for(post in response.body()!!.post_list){
                    _postList.add(post)
                }
                postList.postValue(_postList)
            } else {
                Log.d("tag", "getPosts Error: ${response.code()}")
            }
        }
    }
}