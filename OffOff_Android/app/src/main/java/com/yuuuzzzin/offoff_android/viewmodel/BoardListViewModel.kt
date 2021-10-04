package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.LogUtils.logCoroutineThread
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

    private val _boardList = MutableLiveData<List<Board>>()
    val boardList: LiveData<List<Board>> get() = _boardList

    init {
        getBoardList()
    }

    private fun getBoardList() = viewModelScope.launch(Dispatchers.IO) {
        repository.getBoardList().let { response ->
            if (response.isSuccessful) {
                logCoroutineThread()
                Log.d("tag_success", "getBoardList: ${response.body()}")
                _boardList.postValue(response.body()!!.boardList)
            } else {
                Log.d("tag_", "getBoardList Error: ${response.code()}")
            }
        }
    }
}