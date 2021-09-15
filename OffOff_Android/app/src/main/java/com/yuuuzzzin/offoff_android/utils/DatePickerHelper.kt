package com.yuuuzzzin.offoff_android.utils

import android.app.DatePickerDialog
import android.app.DatePickerDialog.OnDateSetListener
import android.content.Context
import com.yuuuzzzin.offoff_android.R
import java.text.SimpleDateFormat
import java.util.*

class DatePickerHelper(context: Context, isSpinnerType: Boolean = false) {

    private var dialog: DatePickerDialog
    private var callback: Callback? = null

    private val listener = OnDateSetListener { datePicker, year, monthOfYear, dayOfMonth ->
        callback?.onDateSelected(dayOfMonth, monthOfYear, year)
    }

    init {
        val style = if (isSpinnerType) R.style.SpinnerDatePickerDialog else 0

        val cal = Calendar.getInstance()

        dialog = DatePickerDialog(context, style, listener,
            cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DAY_OF_MONTH))
    }

    fun showDialog(dayofMonth: Int, month: Int, year: Int, callback: Callback?) {
        this.callback = callback
        dialog.datePicker.init(year, month, dayofMonth, null)
        dialog.show()
    }

    fun setMinDate(minDate: Long) {
        dialog.datePicker.minDate = minDate
    }

    fun setMaxDate(maxDate: Long) {
        dialog.datePicker.maxDate = maxDate
    }

    fun convertDateToLong(date: String): Long {
        val df = SimpleDateFormat("yyyy.MM.dd")
        return df.parse(date).time
    }

    interface Callback {
        fun onDateSelected(dayofMonth: Int, month: Int, year: Int)
    }
}