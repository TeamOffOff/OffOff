package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
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

    private val _response = MutableLiveData<PostList>()
    val responsePost: LiveData<PostList>
        get() = _response

    init {
        getAllPosts()
    }

    private fun getAllPosts() = viewModelScope.launch {
        repository.getPosts().let { response ->
            if (response.isSuccessful) {
                Log.d("tag", response.body().toString())
                _response.postValue(response.body())
            } else {
                Log.d("tag", "getPosts Error: ${response.code()}")
            }
        }
    }
}