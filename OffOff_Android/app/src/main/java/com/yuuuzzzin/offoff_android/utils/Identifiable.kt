package com.yuuuzzzin.offoff_android.utils

interface Identifiable {
    val identifier: Any

    override operator fun equals(other: Any?): Boolean
}