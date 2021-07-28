package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PostViewModel
@Inject
constructor(
    private val repository: BoardRepository
): ViewModel() {

//    private val postId: String = savedStateHandle["id"] ?:
//        throw IllegalArgumentException("missing post id")
//    private val postBoardType: String = savedStateHandle["board_type"] ?:
//        throw IllegalArgumentException("missing post board type")

    val postId = MutableLiveData<String>()
    val postBoardType = MutableLiveData<String>()

    private val _response = MutableLiveData<Post>()
    val responsePost: LiveData<Post>
        get() = _response

//    init {
//        getPost(postId, postBoardType)
//    }

    fun getPost(postId: String, postBoardType: String) = viewModelScope.launch {
        repository.getPost(postId, postBoardType).let {response ->

            if (response.isSuccessful){
                _response.postValue(response.body())
                Log.d("tag_success", response.body().toString())
            } else {
                Log.d("tag_fail", "getPost Error: ${response.code()}")
            }
        }
    }
}