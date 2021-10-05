package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.PostSend
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PostWriteViewModel
@Inject
constructor(
    private val repository: BoardRepository,
) : ViewModel() {

//    val title: MutableLiveData<String> by lazy {
//        MutableLiveData<String>()
//    }
//
//    val content: MutableLiveData<String> by lazy {
//        MutableLiveData<String>()
//    }

    val title = MutableLiveData("")
    val content = MutableLiveData("")

    private val _alertMsg = MutableLiveData<Event<String>>()
    val alertMsg: LiveData<Event<String>> = _alertMsg

    private val _successEvent = MutableLiveData<Event<String>>()
    val successEvent: LiveData<Event<String>> = _successEvent

    fun setPostText(title: String, content: String) {
        this.title.postValue(title)
        this.content.postValue(content)
    }

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

        val token = OffoffApplication.pref.token // 토큰

        if (token.isNullOrEmpty()) return

        val post = PostSend(
            boardType = boardType,
            author = OffoffApplication.user.subInfo.nickname,
            title = title.value!!,
            content = content.value!!,
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.writePost(token, post).let { response ->
                if (response.isSuccessful) {
                    _successEvent.postValue(Event(response.body()!!.id))
                    Log.d("tag_success", "writePost: ${response.body()}")
                } else {
                    Log.d("tag_fail", "writePost Error: ${response.code()}")
                }
            }
        }
    }

    fun editPost(boardType: String, postId: String) {
        if (!check()) return

        val post = PostSend(
            id = postId,
            boardType = boardType,
            author = "유진박",
            title = title.value!!,
            content = content.value!!
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.editPost(post).let { response ->
                if (response.isSuccessful) {
                    _successEvent.postValue(Event(response.body()!!.id))
                    Log.d("tag_success", "editPost: ${response.body()}")
                } else {
                    Log.d("tag_fail", "editPost Error: ${response.code()}")
                }
            }
        }
    }
}