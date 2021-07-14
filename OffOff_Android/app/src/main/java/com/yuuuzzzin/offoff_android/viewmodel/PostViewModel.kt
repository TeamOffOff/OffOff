package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.*
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PostViewModel
@Inject
constructor(
    savedStateHandle: SavedStateHandle,
    private val repository: BoardRepository
): ViewModel() {

    private val postId: String = savedStateHandle["id"] ?:
        throw IllegalArgumentException("missing post id")

    private val _response = MutableLiveData<Post>()
    val responsePost: LiveData<Post>
        get() = _response

    init {
        getPost(postId)
    }

    private fun getPost(postId : String) = viewModelScope.launch {
        repository.getPost(postId).let {response ->

            if (response.isSuccessful){
                _response.postValue(response.body())
                Log.d("tag_success", response.body().toString())
            } else {
                Log.d("tag_fail", "getPost Error: ${response.code()}")
            }
        }
    }
}