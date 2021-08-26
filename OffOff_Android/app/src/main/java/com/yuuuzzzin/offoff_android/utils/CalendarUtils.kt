package com.yuuuzzzin.offoff_android.utils

object CalendarUtils {

    enum class WeekOfDayType(val value: Int) {
        일(1),
        월(2),
        화(3),
        수(4),
        목(5),
        금(6),
        토(7);

        companion object {
            fun fromInt(value: Int) = values().first { it.value == value }
        }

    }

}


