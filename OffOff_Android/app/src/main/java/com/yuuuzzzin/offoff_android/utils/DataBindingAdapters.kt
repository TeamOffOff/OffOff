package com.yuuuzzzin.offoff_android.utils

import android.view.View
import androidx.databinding.BindingAdapter
import com.google.android.material.textfield.TextInputEditText

object DataBindingAdapters {



    @JvmStatic
    @BindingAdapter("onFocusChange")
    fun bindFocusChange(view: TextInputEditText, listener: View.OnFocusChangeListener?) {
        view.onFocusChangeListener = listener
    }
}