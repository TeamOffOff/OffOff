package com.yuuuzzzin.offoff_android.database.repository

import com.yuuuzzzin.offoff_android.database.dao.ShiftDao
import com.yuuuzzzin.offoff_android.database.models.Shift
import io.realm.Realm
import javax.inject.Inject

/* 뷰모델은 비즈니스 로직에 집중할 수 있도록 db 작업은 리포지토리를 거쳐 수행
* ViewModel <-> Repository <-> DAO
*/

class ScheduleDataBaseRepository @Inject
constructor(
    private val shiftDao: ShiftDao, private val realm: Realm
) {

    val allShifts = shiftDao.getAllShifts()

    fun getAllShift() {
        shiftDao.getAllShift()
    }

    fun insertShift(shift: Shift) {
        shiftDao.insertShift(shift)
    }

    fun deleteAllShifts() {
        shiftDao.deleteAllShifts()
    }
}