package com.yuuuzzzin.offoff_android.utils

import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*

object DateUtils {

    val currentTime: Long = System.currentTimeMillis()
    val currentDate: Date = Date(System.currentTimeMillis())
    val currentLocalDate: LocalDate = LocalDate.now()

    val dateFormat = SimpleDateFormat("yyyy/MM/dd HH:mm:ss")
    val dateFormatWithoutYear = SimpleDateFormat("MM/dd HH:mm")
    val dateFormatYearFirst = SimpleDateFormat("yyyy/MM/dd")
    val dateFormatMonthFirst = SimpleDateFormat("MM/dd")
    val dateFormatHourFirst = SimpleDateFormat("HH:mm")

    val dateFormatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm")
    val dateFormatterWithoutYear = DateTimeFormatter.ofPattern("MM/dd HH:mm")
    val dateFormatterYearFirst = DateTimeFormatter.ofPattern("yyyy/MM/dd")
    val dateFormatterMonthFirst = DateTimeFormatter.ofPattern("MM/dd")
    val dateFormatterHourFirst = DateTimeFormatter.ofPattern("HH:mm")

    fun convertStringToLocalDate(string: String): LocalDateTime {
        val formatter = DateTimeFormatter.ofPattern("yyyy년 MM월 dd일 HH시 mm분")
        return LocalDateTime.parse(string, formatter)
    }

    fun calculateLocalDate(localDateTime: LocalDateTime): String {
        if (localDateTime.year == currentLocalDate.year && localDateTime.month == currentLocalDate.month && localDateTime.dayOfMonth == currentLocalDate.dayOfMonth) {
            return dateFormatterHourFirst.format(localDateTime)
        }
        return dateFormatterMonthFirst.format(localDateTime)
    }
}