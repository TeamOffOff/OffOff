package com.yuuuzzzin.offoff_android.utils

import android.content.Context
import android.widget.Toast
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import kotlin.math.roundToInt

object Constants {

    const val DATABASE_NAME = "offoff-db"
    const val SCHEDULE_DATA_FILENAME = "schedule.json"

    const val NETWORK_DISCONNECT = "네트워크 연결 상태를 확인해주세요."

    // 댓글 옵션
    const val DELETE_COMMENT = "삭제"
    const val REPORT_COMMENT = "신고"

    // MutableLiveData에 저장된 값 가져오기
    fun MutableLiveData<String>.get(): String {
        return this.value ?: ""
    }

    fun <T> LiveData<T>.observeOnce(lifecycleOwner: LifecycleOwner, observer: Observer<T>) {
        observe(lifecycleOwner, object : Observer<T> {
            override fun onChanged(t: T?) {
                observer.onChanged(t)
                removeObserver(this)
            }
        })
    }

    fun Context.toast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    fun convertDPtoPX(context: Context, dp: Int): Int {
        val density: Float = context.resources.displayMetrics.density
        return (dp.toFloat() * density).roundToInt()
    }

    fun convertPXtoDP(context: Context, px: Int): Int {
        val density: Float = context.resources.displayMetrics.density
        return (px.toFloat() / density).roundToInt()
    }

    fun getBoardName(boardType: String) : String {
        return when (boardType) {
            "free" -> BoardType.FREE
            "secret" -> BoardType.SECRET
            "hot" -> BoardType.HOT
            "Information" -> BoardType.INFO
            else -> BoardType.FREE
        }
    }

}

object PostWriteType {
    const val EDIT = 1 // post 수정
    const val WRITE = 2 // post 작성
}

object BoardType {
    const val FREE = "자유게시판"
    const val SECRET = "비밀게시판"
    const val HOT = "인기게시판"
    const val INFO = "정보게시판"
}

object UserPostType {
    const val MY_POST = "내가 쓴 글"
    const val MY_COMMENT_POST = "댓글 단 글"
    const val MY_BOOKMARK_POST = "스크랩한 글"
}