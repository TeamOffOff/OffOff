package com.yuuuzzzin.offoff_android.database.repository

import com.yuuuzzzin.offoff_android.database.dao.ShiftDao
import com.yuuuzzzin.offoff_android.database.models.SavedShift
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

    // 저장된 모든 근무타입
    val shiftList = shiftDao.getAllShifts()

    // 모든 근무타입 라이브데이터로 가져오기
    fun getAllShifts() = shiftDao.getAllShifts()

    // 모든 근무타입 가져오기
    fun getAllShift() = shiftDao.getAllShift()

    // 특정 근무타입 가져오기
    fun getShift(id: String) = shiftDao.getShift(id)

    // 근무타입 추가
    fun insertShift(shift: Shift) = shiftDao.insertShift(shift)

    // 근무타입 수정
    // fun updateShift(shift: Shift) = shiftDao.updateShift(shift)

    // 특정 근무타입 삭제
    fun deleteShift(id: Int) = shiftDao.deleteShift(id)

    // 모든 근무타입 삭제
    fun deleteAllShifts() = shiftDao.deleteAllShifts()

    // id max 값 + 1 반환하는 메소드
    fun getNextId(): Int = shiftDao.getNextId()

    // 저장된 모든 일정
    val scheduleList = shiftDao.getAllSchedule()

    // 모든 일정 라이브데이터로 가져오기
    fun getAllSchedule() = shiftDao.getAllSchedule()

    // 모든 일정 가져오기
    fun getAllS() = shiftDao.getAllS()

    // 해당 날짜의 일정 가져오기
    fun getSchedule(year: Int, month: Int, day: Int) = shiftDao.getSchedule(year, month, day)

    // 일정 추가
    fun insertSchedule(savedShift: SavedShift) = shiftDao.insertSchedule(savedShift)

    // 특정 일정 삭제
    fun deleteSchedule(id: String) = shiftDao.deleteSchedule(id)

    // 모든 일정 삭제
    fun deleteAllSchedule() = shiftDao.deleteAllSchedule()

    // 일정 id max 값 + 1 반환하는 메소드
    fun getNextScheduleId(): Int = shiftDao.getNextScheduleId()

}