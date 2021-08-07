package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.service.models.BoardList
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

    private val _response = MutableLiveData<BoardList>()
    val response: LiveData<BoardList>
        get() = _response

    init {
        getBoardList()
    }

    private fun getBoardList() = viewModelScope.launch {
        repository.getBoardList().let { response ->
            if (response.isSuccessful) {
                for(board in response.body()!!.board_list){
                    _boardList.add(board)
                }
                boardList.postValue(_boardList)
            } else {
                Log.d("tag", "getBoardList Error: ${response.code()}")
            }
        }
    }
}