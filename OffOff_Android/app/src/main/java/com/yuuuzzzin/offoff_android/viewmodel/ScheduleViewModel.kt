package com.yuuuzzzin.offoff_android.viewmodel

import androidx.lifecycle.ViewModel
import com.yuuuzzzin.offoff_android.database.RealmLiveData
import com.yuuuzzzin.offoff_android.database.dao.ShiftDao
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.database.repository.ScheduleDataBaseRepository
import com.yuuuzzzin.offoff_android.service.repository.ScheduleServiceRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import io.realm.Realm
import javax.inject.Inject

@HiltViewModel
class ScheduleViewModel
@Inject
constructor(
    private val serviceRepository: ScheduleServiceRepository,
) : ViewModel() {

    private val dbRepository: ScheduleDataBaseRepository
    private val realm: Realm = Realm.getDefaultInstance()

    val allShifts: RealmLiveData<Shift>

    init {
        dbRepository = ScheduleDataBaseRepository(ShiftDao(realm))
        allShifts = dbRepository.allShifts
    }

    fun insertShift(shift: Shift) {
        dbRepository.insertShift(shift)
    }

    fun deleteAllShifts() {
        dbRepository.deleteAllShifts()
    }

    override fun onCleared() {
        super.onCleared()
        realm.close()
    }

}