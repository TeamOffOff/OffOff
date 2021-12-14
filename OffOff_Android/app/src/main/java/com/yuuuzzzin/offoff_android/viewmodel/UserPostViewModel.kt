package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.repository.ActivityRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class UserPostViewModel
@Inject
constructor(
    private val repository: ActivityRepository
) : ViewModel() {

    private val _loading = MutableLiveData<Event<Boolean>>()
    val loading: LiveData<Event<Boolean>> = _loading

    private val _postList = MutableLiveData<List<Post>>()
    val postList: LiveData<List<Post>> get() = _postList

    fun getMyPostList(isRefreshing: Boolean) {

        if (!isRefreshing)
            _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.getMyPostList(OffoffApplication.pref.token!!).let { response ->
                if (response.isSuccessful) {

                    if (!isRefreshing)
                        _loading.postValue(Event(false))

                    Log.d("tag_success", "getMyPostList: ${response.body()}")

                    if (!response.body()!!.postList.isNullOrEmpty()) {
                        _postList.postValue(response.body()!!.postList)
                    }
                } else {
                    Log.d("tag_fail", "getMyPostList Error: ${response.code()}")
                }
            }
        }
    }

    fun getMyCommentPostList(isRefreshing: Boolean) {

        if (!isRefreshing)
            _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.getMyCommentPostList(OffoffApplication.pref.token!!).let { response ->
                if (response.isSuccessful) {

                    if (!isRefreshing)
                        _loading.postValue(Event(false))

                    Log.d("tag_success", "getMyCommentPostList: ${response.body()}")

                    if (!response.body()!!.postList.isNullOrEmpty()) {
                        _postList.postValue(response.body()!!.postList)
                    }
                } else {
                    Log.d("tag_fail", "getMyCommentPostList Error: ${response.code()}")
                }
            }
        }
    }

    fun getMyBookmarkPostList(isRefreshing: Boolean) {

        if (!isRefreshing)
            _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.getMyBookmarkPostList(OffoffApplication.pref.token!!).let { response ->
                if (response.isSuccessful) {

                    if (!isRefreshing)
                        _loading.postValue(Event(false))

                    Log.d("tag_success", "getMyBookmarkPostList: ${response.body()}")

                    if (!response.body()!!.postList.isNullOrEmpty()) {
                        _postList.postValue(response.body()!!.postList)
                    }
                } else {
                    Log.d("tag_fail", "getMyBookmarkPostList Error: ${response.code()}")
                }
            }
        }
    }
}