package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.Image
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PostImagesViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    private val _loading = MutableLiveData<Event<Boolean>>()
    val loading: LiveData<Event<Boolean>> = _loading

    private val _imageList = MutableLiveData<List<Image>>()
    val imageList: LiveData<List<Image>> get() = _imageList

    fun getPostImages(postId: String, boardType: String) {

        _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.getPostImages(OffoffApplication.pref.token.toString(), postId, boardType)
                .let { response ->
                    if (response.isSuccessful) {
                        _loading.postValue(Event(false))
                        _imageList.postValue(response.body()!!.image)
                        //OffoffApplication.imageList = response.body()!!.image
                        Log.d("tag_success", "getPostImages: ${response.body()}")
                    } else {
                        Log.d("tag_fail", "getPostImages Error: ${response.code()}")
                    }
                }

        }
    }
}