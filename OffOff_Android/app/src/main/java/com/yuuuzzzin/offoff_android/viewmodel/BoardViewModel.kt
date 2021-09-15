package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
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

    private val _postList = MutableLiveData<List<Post>>()
    val postList: LiveData<List<Post>> get() = _postList

    private var count: Int = 0 // 가져온 아이템 개수

    fun getPosts(boardType: String) = viewModelScope.launch(Dispatchers.IO) {
        repository.getPosts(boardType).let { response ->
            if (response.isSuccessful) {
                Log.d("tag_success", "getPosts: ${response.body()}")
                if (!response.body()!!.postList.isNullOrEmpty()) {
                    _postList.postValue(response.body()!!.postList)
                    count = response.body()!!.postList.size
                }
            } else {
                Log.d("tag_fail", "getPosts Error: ${response.code()}")
            }
        }
    }
}