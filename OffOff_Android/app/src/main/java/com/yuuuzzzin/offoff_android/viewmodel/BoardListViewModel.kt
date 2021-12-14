package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class BoardListViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    private val _loading = MutableLiveData<Event<Boolean>>()
    val loading: LiveData<Event<Boolean>> = _loading

    private val _boardList = MutableLiveData<List<Board>>()
    val boardList: LiveData<List<Board>> get() = _boardList

    private val _postList = MutableLiveData<List<Post>>()
    val postList: LiveData<List<Post>> get() = _postList

    private val _lastPostId = MutableLiveData<String>()
    val lastPostId: LiveData<String> get() = _lastPostId

    init {
        getBoardList()
    }

    private fun getBoardList() {

        _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.getBoardList().let { response ->
                if (response.isSuccessful) {
                    _loading.postValue(Event(false))
                    Log.d("tag_success", "getBoardList: ${response.body()}")
                    _boardList.postValue(response.body()!!.boardList)
                } else {
                    Log.d("tag_", "getBoardList Error: ${response.code()}")
                }
            }
        }
    }

    fun totalSearchPost(key: String, lastPostId: String?) {

        _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.totalSearchPost(OffoffApplication.pref.token.toString(), key, lastPostId)
                .let { response ->
                    if (response.isSuccessful) {
                        _loading.postValue(Event(false))
                        Log.d("tag_success", "totalSearchPost: ${response.body()}")
                        _postList.postValue(response.body()!!.postList)

                        if (!response.body()!!.postList.isNullOrEmpty()) {
                            _lastPostId.postValue(response.body()!!.lastPostId)
                        }
                    } else {
                        Log.d("tag_fail", "totalSearchPost Error: ${response.code()}")
                    }
                }
        }
    }
}