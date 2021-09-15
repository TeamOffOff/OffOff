package com.yuuuzzzin.offoff_android.utils.base

import android.util.Log
import com.yuuuzzzin.offoff_android.utils.LogUtils.logCoroutineThread
import com.yuuuzzzin.offoff_android.utils.ResponseData
import org.json.JSONObject
import retrofit2.Response

abstract class BaseRepository {

    suspend fun <T> apiCall(apiCall: suspend () -> Response<T>): ResponseData<T> {

        try {
            val response = apiCall()

            if (response.isSuccessful) {
                logCoroutineThread()
                val body = response.body()
                if (body != null) {
                    Log.d("tag_success", "응답 바디 : ${response.body()}")
                    return ResponseData.success(body)
                }
            }

            else{
                val errorResponse = response.errorBody()?.toString()
                val errorMessage = StringBuilder()

                errorMessage.append(JSONObject(errorResponse).getString("queryStatus"))
                errorMessage.append("ERROR CODE : ${response.code()}")

                return ResponseData.error(errorMessage.toString())
            }

            return ResponseData.failed("응답 요청 실패")

        } catch (e: Exception) {
            return ResponseData.failed("응답 요청 실패 | $e")
        }
    }
}