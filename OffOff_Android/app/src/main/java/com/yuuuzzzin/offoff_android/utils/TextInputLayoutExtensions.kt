package com.yuuuzzzin.offoff_android.utils

import android.content.res.ColorStateList
import androidx.core.content.ContextCompat
import com.google.android.material.textfield.TextInputLayout
import com.yuuuzzzin.offoff_android.R

fun TextInputLayout.setValidColor() {
    setBoxStrokeColorStateList(ContextCompat.getColorStateList(context, R.color.box_stroke_color_valid)!!)
    defaultHintTextColor = ColorStateList.valueOf(ContextCompat.getColor(context, R.color.green))
}

fun TextInputLayout.setDefaultColor() {
    setBoxStrokeColorStateList(ContextCompat.getColorStateList(context, R.color.box_stroke_color_default)!!)
    defaultHintTextColor = ColorStateList.valueOf(ContextCompat.getColor(context, R.color.material_on_background_disabled))
}

fun TextInputLayout.setErrorColor() {
    setBoxStrokeColorStateList(ContextCompat.getColorStateList(context, R.color.box_stroke_color_valid)!!)
    defaultHintTextColor = ColorStateList.valueOf(ContextCompat.getColor(context, R.color.green))
}

fun TextInputLayout.setAcceptColor() {
    defaultHintTextColor = ColorStateList.valueOf(ContextCompat.getColor(context, R.color.box_stroke_color_valid))
    setBoxStrokeColorStateList(ContextCompat.getColorStateList(context, R.color.box_stroke_color_valid)!!)
}