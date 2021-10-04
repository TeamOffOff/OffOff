package com.yuuuzzzin.offoff_android.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.database.repository.ScheduleDataBaseRepository
import com.yuuuzzzin.offoff_android.service.repository.ScheduleServiceRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class ShiftSettingViewModel
@Inject
constructor(
    private val serviceRepository: ScheduleServiceRepository,
    private val dbRepository: ScheduleDataBaseRepository
) : ViewModel() {

    val title: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }

    fun initEtShift() {
        title.value = "D"
    }

    fun initEtShift(title: String) {
        this.title.value = title
    }

    fun getShift(id: String): Shift? = dbRepository.getShift(id)

    fun insertShift(shift: Shift) {
        dbRepository.insertShift(shift)
    }

    // 나중에 삭제 필요
    fun getNextId(): Int {
        return dbRepository.getNextId()
    }

}