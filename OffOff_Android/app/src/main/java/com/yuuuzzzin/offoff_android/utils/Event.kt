package com.yuuuzzzin.offoff_android.utils

/* 이벤트 처리 여부를 담당하는 Event Wrapper */

open class Event<out T>(private val content: T) {

    var hasBeenHandled = false
        private set

    fun getContentIfNotHandled(): T? {
        return if (hasBeenHandled) { // 이벤트가 이미 처리되었다면
            null // null울 반환
        } else { // 아직 처리되지 않았다면
            hasBeenHandled = true // 이벤트가 처리되었다고 표시하고
            content // 값을 반환
        }
    }

    fun peekContent(): T = content
}