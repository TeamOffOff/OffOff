package com.yuuuzzzin.offoff_android.utils

import androidx.databinding.ObservableBoolean
import androidx.databinding.ObservableField
import java.util.regex.Pattern

object Validation {

    fun validateId(id: ObservableField<String>): Boolean {
        val valid = Pattern.compile(Constants.ID_REGEX).matcher(id.get()).matches()
        return valid
    }

    fun validatePw(pw: ObservableField<String>, pwValid: ObservableBoolean): Boolean {
        val valid = validate(Constants.PW_REGEX, pw.getOrEmpty() )
        pwValid.set(valid)
        return valid
    }

    fun validatePwConfirm(pw: ObservableField<String>, pwConfirm: ObservableField<String>, pwConfirmValid: ObservableBoolean): Boolean {
        val valid = (pw.get() == pwConfirm.get()) && validate(Constants.PW_REGEX, pw.getOrEmpty())
        pwConfirmValid.set(valid)
        return valid
    }

    private fun validate(patter: String, string: String): Boolean {
        return Pattern.compile(patter).matcher(string).matches()
    }
}