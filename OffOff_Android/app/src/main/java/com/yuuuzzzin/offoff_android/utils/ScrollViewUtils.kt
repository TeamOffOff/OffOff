package com.yuuuzzzin.offoff_android.utils

import android.animation.ObjectAnimator
import android.graphics.Rect
import android.view.View
import androidx.core.widget.NestedScrollView

object ScrollViewUtils {

    // 해당 뷰까지 스크롤을 이동
    fun NestedScrollView.scrollToView(view: View, marginTop: Int = 0) {
        val y = calculateDistance(view) - marginTop
        this.scrollTo(0, y)
    }

    // 해당 뷰까지 스크롤을 부드럽게 이동
    fun NestedScrollView.smoothScrollToView(view: View, marginTop: Int = 0) {
        val y = calculateDistance(view) - marginTop
        ObjectAnimator.ofInt(this, "scrollY", y).apply {
            duration = 1000L
        }.start()
    }

    // 스크롤뷰와 해당 뷰 사이의 거리 계산
    private fun NestedScrollView.calculateDistance(view: View): Int {
        return kotlin.math.abs(
            calculateView(this).top - (this.scrollY + calculateView(
                view
            ).top)
        )
    }

    // 스크린 내의 뷰 절대 좌표 계산
    private fun calculateView(view: View): Rect {
        val location = IntArray(2)
        view.getLocationOnScreen(location)
        return Rect(
            location[0],
            location[1],
            location[0] + view.measuredWidth,
            location[1] + view.measuredHeight
        )
    }
}