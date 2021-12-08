package com.yuuuzzzin.offoff_android.utils

import android.graphics.drawable.Drawable
import androidx.annotation.*
import androidx.core.content.ContextCompat
import com.yuuuzzzin.offoff_android.OffoffApplication

object ResUtils {

    fun getColor(@ColorRes id: Int): Int = ContextCompat.getColor(OffoffApplication.appCtx(), id)
    fun getString(@StringRes id: Int): String = OffoffApplication.appCtx().getString(id)
    fun getDrawable(@DrawableRes id: Int): Drawable? = ContextCompat.getDrawable(OffoffApplication.appCtx(), id)
    fun getStringArray(@ArrayRes id: Int): Array<String> = OffoffApplication.appCtx().resources.getStringArray(id)

    fun hideLayout(layoutRes: LayoutRes) {

    }
}