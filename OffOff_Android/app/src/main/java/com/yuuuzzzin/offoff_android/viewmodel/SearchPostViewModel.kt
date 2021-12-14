package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SearchPostViewModel
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

    fun searchPost(boardType: String, key: String, lastPostId: String?) {

        _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.searchPost(
                OffoffApplication.pref.token.toString(),
                boardType,
                key,
                lastPostId
            ).let { response ->
                if (response.isSuccessful) {
                    _loading.postValue(Event(false))
                    Log.d("tag_success", "searchPost: ${response.body()}")
                    _postList.postValue(response.body()!!.postList)

                    if (!response.body()!!.postList.isNullOrEmpty()) {
                        _lastPostId.postValue(response.body()!!.lastPostId)
                    }
                } else {
                    Log.d("tag_fail", "searchPost Error: ${response.code()}")
                }
            }
        }
    }
}