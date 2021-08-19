package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.service.models.Author
import com.yuuuzzzin.offoff_android.service.models.PostSend
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.DateUtils.currentTime
import com.yuuuzzzin.offoff_android.utils.DateUtils.dateFormat
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PostWriteViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    val title = MutableLiveData("")
    val content = MutableLiveData("")

    private val _alertMsg = MutableLiveData<Event<String>>()
    val alertMsg: LiveData<Event<String>> = _alertMsg

    private val _successEvent = MutableLiveData<Event<String>>()
    val successEvent: LiveData<Event<String>> = _successEvent

    private fun check(): Boolean {

        var checkValue = true

        if (title.value.isNullOrBlank()) {
            _alertMsg.value = Event("제목을 입력해주세요")
            checkValue = false
        } else if (content.value.isNullOrBlank()) {
            _alertMsg.value = Event("내용을 입력해주세요")
            checkValue = false
        }

        return checkValue
    }

    fun writePost(boardType: String) {
        if (!check()) return

        val post = PostSend(
            boardType = boardType,
            author = Author(
                id = "yujin12"
            ),
            date = dateFormat.format(currentTime),
            title = title.value!!,
            content = content.value!!
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.writePost(post).let { response ->
                if (response.isSuccessful) {
                    _successEvent.postValue(Event(response.body()!!.id))
                    Log.d("tag_success", "writePost: ${response.body()}")
                } else {
                    Log.d("tag_fail", "writePost Error: ${response.code()}")
                }
            }
        }
    }
}