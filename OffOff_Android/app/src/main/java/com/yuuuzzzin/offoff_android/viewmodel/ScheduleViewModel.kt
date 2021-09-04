package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.database.repository.ScheduleDataBaseRepository
import com.yuuuzzzin.offoff_android.service.repository.ScheduleServiceRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import io.realm.RealmResults
import javax.inject.Inject

@HiltViewModel
class ScheduleViewModel
@Inject
constructor(
    private val serviceRepository: ScheduleServiceRepository,
    private val dbRepository: ScheduleDataBaseRepository
) : ViewModel() {

    private val _shiftList: LiveData<RealmResults<Shift>> = dbRepository.allShifts
    val shiftList: LiveData<RealmResults<Shift>> get() = _shiftList

    init {
        Log.d("tag_realm_test", getAllShift().toString())
    }

    fun getAllShift() {
        dbRepository.getAllShift()
    }

    fun insertShift(shift: Shift) {
        dbRepository.insertShift(shift)
    }

    fun deleteAllShifts() {
        dbRepository.deleteAllShifts()
    }

}