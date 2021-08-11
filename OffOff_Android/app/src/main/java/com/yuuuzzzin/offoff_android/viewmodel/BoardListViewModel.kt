package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class BoardListViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    private val _boardList = ArrayList<Board>()
    val boardList: MutableLiveData<ArrayList<Board>> by lazy{
        MutableLiveData<ArrayList<Board>>()
    }

    init {
        getBoardList()
    }

    private fun getBoardList() = viewModelScope.launch {
        repository.getBoardList().let { response ->
            if (response.isSuccessful) {
                Log.d("tag_success", "getBoardList: ${response.body()}")
                for(board in response.body()!!.boardList){
                    _boardList.add(board)
                }
                boardList.postValue(_boardList)
            } else {
                Log.d("tag_", "getBoardList Error: ${response.code()}")
            }
        }
    }
}