package com.yuuuzzzin.offoff_android.utils

import android.view.View
import androidx.databinding.BindingAdapter

object DataBindingAdapters {
    @JvmStatic
    @BindingAdapter("onFocusChange")
    fun bindFocusChange(view: View, listener: View.OnFocusChangeListener) {
        view.onFocusChangeListener = listener
    }
}