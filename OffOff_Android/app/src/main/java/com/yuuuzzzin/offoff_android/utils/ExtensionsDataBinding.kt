package com.yuuuzzzin.offoff_android.utils

import androidx.databinding.ObservableField

fun ObservableField<String>.getOrEmpty(): String {
    return this.get() ?: ""
}