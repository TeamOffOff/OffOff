package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.yuuuzzzin.offoff_android.database.models.SavedShift
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.database.repository.ScheduleDataBaseRepository
import com.yuuuzzzin.offoff_android.service.repository.ScheduleServiceRepository
import com.yuuuzzzin.offoff_android.utils.Event
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

    private val _scheduleChanged = MutableLiveData<Event<Boolean>>()
    val scheduleChanged: LiveData<Event<Boolean>> = _scheduleChanged

    init {
        Log.d("tag_realm_test", getSchedule(2021, 9, 15).toString())
    }

    fun getAllShifts() = dbRepository.getAllShifts()

    fun getAllShift(): List<Shift> {
        return dbRepository.getAllShift()
    }

    fun insertShift(shift: Shift) {
        dbRepository.insertShift(shift)
    }

//    fun updateShift(shift: Shift) {
//        dbRepository.updateShift(shift)
//    }

    fun deleteShift(id: Int) {
        dbRepository.deleteShift(id)
    }

    fun deleteAllShifts() {
        dbRepository.deleteAllShifts()
    }

    // 나중에 삭제 필요
    fun getNextId(): Int {
        return dbRepository.getNextId()
    }

    fun getAllSchedule() = dbRepository.getAllSchedule()

    fun getAllS(): List<SavedShift> {
        return dbRepository.getAllS()
    }

    fun getSchedule(year: Int, month: Int, day: Int): SavedShift? {
        return dbRepository.getSchedule(year, month, day)
    }

    fun insertSchedule(savedShift: SavedShift) {
        dbRepository.insertSchedule(savedShift)
    }

    fun deleteAllSchedule() {
        dbRepository.deleteAllSchedule()
        scheduleChanged()
    }

    // 나중에 삭제 필요
    fun getNextScheduleId(): Int {
        return dbRepository.getNextScheduleId()
    }

    fun scheduleChanged() {

        _scheduleChanged.postValue(Event(true))
    }

}