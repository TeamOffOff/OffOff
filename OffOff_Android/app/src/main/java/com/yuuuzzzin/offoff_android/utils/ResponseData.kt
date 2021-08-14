package com.yuuuzzzin.offoff_android.utils

/* APi 통신 결과 상태를 나타내는 응답 데이터 */

data class ResponseData<out T>(val status: Status, val data: T?, val message: String?) {

    enum class Status {
        SUCCESS,
        ERROR,
        LOADING,
        FAILURE
    }

    companion object {

        fun <T> success(data: T): ResponseData<T> {
            return ResponseData(Status.SUCCESS, data, null)
        }

        fun <T> error(message: String, data: T? = null): ResponseData<T> {
            return ResponseData(Status.ERROR, data, message)
        }

        fun <T> loading(data: T?): ResponseData<T> {
            return ResponseData(Status.LOADING, data, null)
        }

        fun <T> failed(message: String, data: T? = null): ResponseData<T> {
            return ResponseData(Status.FAILURE, data, message)
        }
    }
}
