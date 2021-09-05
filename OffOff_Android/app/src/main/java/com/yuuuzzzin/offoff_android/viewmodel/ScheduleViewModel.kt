package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.database.repository.ScheduleDataBaseRepository
import com.yuuuzzzin.offoff_android.service.repository.ScheduleServiceRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class ScheduleViewModel
@Inject
constructor(
    private val serviceRepository: ScheduleServiceRepository,
    private val dbRepository: ScheduleDataBaseRepository
) : ViewModel() {

    private val _shiftList: LiveData<List<Shift>> = Transformations.map(dbRepository.shiftList) {
        it
    }
    val shiftList: LiveData<List<Shift>> get() = _shiftList

    init {
        Log.d("tag_realm_test", shiftList.value.toString())
    }

    fun getAllShifts() = dbRepository.getAllShifts()

    fun getFirst() = dbRepository.getFirst()

    fun getAllShift(): List<Shift> {
        return dbRepository.getAllShift()
    }

    fun insertShift(shift: Shift) {
        dbRepository.insertShift(shift)
    }

    fun deleteAllShifts() {
        dbRepository.deleteAllShifts()
    }

}