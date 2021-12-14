package com.yuuuzzzin.offoff_android.utils.base

import android.app.Activity
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.databinding.BindingAdapter
import com.yuuuzzzin.offoff_android.utils.DateUtils
import com.yuuuzzzin.offoff_android.utils.DateUtils.calculateLocalDate
import com.yuuuzzzin.offoff_android.utils.DateUtils.convertStringToLocalDate

object BaseBindingAdapters {

    // LocalDateTime 값에 따라 다른 DateFormat 지정
    @JvmStatic
    @BindingAdapter("specificDateFormatText")
    fun setSpecificDateFormatText(textView: TextView, str: String) {
        val localDateTime = convertStringToLocalDate(str)
        val dateFormatText = calculateLocalDate(localDateTime)
        textView.text = dateFormatText
    }

    // LocalDateTime 값에 년도없는 DateFormat 지정
    @JvmStatic
    @BindingAdapter("dateFormatTextWithoutYear")
    fun dateFormatTextWithoutYear(textView: TextView, str: String) {
        val localDateTime = convertStringToLocalDate(str)
        textView.text = DateUtils.dateFormatterWithoutYear.format(localDateTime)
    }

    // LocalDateTime 값에 완전한 형식의 DateFormat 지정
    @JvmStatic
    @BindingAdapter("dateFormatText")
    fun dateFormatText(textView: TextView, str: String) {
        val localDateTime = convertStringToLocalDate(str)
        textView.text = DateUtils.dateFormatter.format(localDateTime)
    }

    // 로딩 레이아웃 가시화 여부와 화면 터치 가능 여부 지정
    @JvmStatic
    @BindingAdapter("loadingLayoutVisibility")
    fun loadingLayoutVisibility(view: View, visibility: Boolean) {
        val activity = view.context as Activity

        if(visibility) {
            view.visibility = View.VISIBLE
            activity.window.setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE, WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        } else {
            view.visibility = View.GONE
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        }
    }

}