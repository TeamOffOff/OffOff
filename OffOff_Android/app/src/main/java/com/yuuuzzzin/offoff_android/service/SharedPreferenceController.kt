package com.yuuuzzzin.offoff_android.service

import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.content.SharedPreferences

class SharedPreferenceController(context: Context) {

    private val TOKEN = "TOKEN"
    //private val ACCESS_TOKEN = "access_token"

    private val pref: SharedPreferences =
        context.getSharedPreferences(TOKEN, MODE_PRIVATE)

    var token: String?
        get() = pref.getString("token", null)
        set(value) {
            pref.edit().putString("token", value).apply()
        }

    fun deleteToken() {
        val edit = pref.edit()
        edit.clear()
        edit.apply()
    }

//    private val NICKNAME = "NICKNAME"
//    //private val ACCESS_TOKEN = "access_token"
//
//    private val pref: SharedPreferences =
//        context.getSharedPreferences(NICKNAME, MODE_PRIVATE)
//
//    var nickname: String?
//        get() = pref.getString("nickname", null)
//        set(value) {
//            pref.edit().putString("nickname", value).apply()
//        }
//
//    fun deleteToken() {
//        val edit = pref.edit()
//        edit.clear()
//        edit.apply()
//    }

//
//    fun setToken(key: String, str: String) {
//        pref.edit().putString(key, str).apply()
//    }
//
//    fun getToken(key: String): String {
//        return pref.getString(key, null).toString()
//    }


//    // Token 저장
//    fun setToken(context: Context, auth: String?) {
//        val pref = context.getSharedPreferences(TOKEN, MODE_PRIVATE)
//        val editor = pref.edit()
//        editor.putString(ACCESS_TOKEN, auth)
//        editor.apply()
//    }
//
//    // Token 불러오기
//    fun getToken(context: Context): String? {
//        val pref = context.getSharedPreferences(TOKEN, MODE_PRIVATE)
//        return pref.getString(ACCESS_TOKEN, "")
//    }
//
//    // Token 삭제
//    fun clearToken(context: Context) {
//        val pref = context.getSharedPreferences(TOKEN, MODE_PRIVATE)
//        val editor = pref.edit()
//        editor.clear()
//        editor.apply()
//    }
}