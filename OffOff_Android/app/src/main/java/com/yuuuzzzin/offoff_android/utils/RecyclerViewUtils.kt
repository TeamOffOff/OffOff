package com.yuuuzzzin.offoff_android.utils

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

object RecyclerViewUtils {

    // 리사이클러뷰 아이템 간의 간격 설정
    class VerticalSpaceItemDecoration(private val verticalSpaceHeight: Int) :
        RecyclerView.ItemDecoration() {

        override fun getItemOffsets(
            outRect: Rect, view: View, parent: RecyclerView,
            state: RecyclerView.State
        ) {
            outRect.bottom = verticalSpaceHeight
        }
    }
}