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
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SearchPostViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    private val _loading = MutableStateFlow<Boolean>(false)
    val loading: StateFlow<Boolean> = _loading

    private val _postList = MutableLiveData<List<Post>>()
    val postList: LiveData<List<Post>> get() = _postList

    private val _lastPostId = MutableLiveData<String>()
    val lastPostId: LiveData<String> get() = _lastPostId

    private val _clearPostList = MutableLiveData<Event<Boolean>>()
    val clearPostList: LiveData<Event<Boolean>> = _clearPostList

    fun searchPost(boardType: String, key: String, lastPostId: String?) =
        viewModelScope.launch(Dispatchers.IO) {
            repository.searchPost(
                OffoffApplication.pref.token.toString(),
                boardType,
                key,
                lastPostId
            ).let { response ->
                if (response.isSuccessful) {
                    Log.d("tag_success", "searchPost: ${response.body()}")
//                    if (!response.body()!!.postList.isNullOrEmpty()) {
                        Log.d("tag_search","참")
                            _postList.postValue(response.body()!!.postList)
                    if (!response.body()!!.postList.isNullOrEmpty()) {
                        _lastPostId.postValue(response.body()!!.lastPostId)
                    }

//                    } else {
//                        Log.d("tag_search","빔")
//                        //_clearPostList.postValue(Event(true))
//                    }
                } else {
                    Log.d("tag_fail", "searchPost Error: ${response.code()}")
                }
            }
        }

    fun totalSearchPost(key: String, lastPostId: String?) =
        viewModelScope.launch(Dispatchers.IO) {
            repository.totalSearchPost(OffoffApplication.pref.token.toString(), key, lastPostId)
                .let { response ->
                    if (response.isSuccessful) {
                        Log.d("tag_success", "totalSearchPost: ${response.body()}")
                        if (!response.body()!!.postList.isNullOrEmpty()) {
                            _postList.postValue(response.body()!!.postList)
                            _lastPostId.postValue(response.body()!!.lastPostId)
                        }
                    } else {
                        Log.d("tag_fail", "totalSearchPost Error: ${response.code()}")
                    }
                }
        }

}