package com.yuuuzzzin.offoff_android.database.dao

import com.yuuuzzzin.offoff_android.database.asLiveData
import com.yuuuzzzin.offoff_android.database.models.SavedShift
import com.yuuuzzzin.offoff_android.database.models.Shift
import io.realm.Realm
import io.realm.RealmResults
import io.realm.Sort
import io.realm.kotlin.where

/* 리포지토리에서 접근할 ShiftDao 클래스 */

class ShiftDao(private val realm: Realm) {

    // 모든 근무타입 라이브데이터로 가져오기
    fun getAllShifts() = realm.where<Shift>()
        .findAllAsync()
        .asLiveData()

    // 모든 근무타입 가져오기
    fun getAllShift(): RealmResults<Shift> {
        return realm.where<Shift>()
            .findAll()
            .sort("id", Sort.ASCENDING)
    }

    // 근무타입 추가
    fun insertShift(shift: Shift) {
        realm.executeTransactionAsync {
            it.insert(shift)
        }
    }

    // 특정 근무타입 삭제
    fun deleteShift(id: String) {
        realm.executeTransaction {
            it.where<Shift>().equalTo("id", id).findAll().deleteAllFromRealm()
        }
    }

    // 모든 근무타입 삭제
    fun deleteAllShifts() {
        realm.executeTransaction {
            it.where<Shift>().findAll().deleteAllFromRealm()
        }
    }

    // id max 값 + 1 반환하는 메소드
    fun getNextId(): Int {
        val maxId = realm.where<Shift>()
            .max("id")
        if (maxId != null) {
            return maxId.toInt() + 1
        }
        return 0
    }

    // 모든 일정 라이브데이터로 가져오기
    fun getAllSchedule() = realm.where<SavedShift>()
        .findAllAsync()
        .asLiveData()

    // 모든 일정 가져오기
    fun getAllS(): RealmResults<SavedShift> {
        return realm.where<SavedShift>()
            .findAll()
            .sort("id", Sort.ASCENDING)
    }

    // 해당 날짜의 일정 가져오기
    fun getSchedule(year: Int, month: Int, day: Int): SavedShift? = realm.where<SavedShift>()
        .equalTo("date", (String.format("%04d-%02d-%02d", year, month, day)))
        .findFirst()

    // 일정 추가
    fun insertSchedule(savedShift: SavedShift) {
        realm.executeTransactionAsync {
            it.insert(savedShift)
        }
    }

    // 특정 일정 삭제
    fun deleteSchedule(id: String) {
        realm.executeTransaction {
            it.where<SavedShift>().equalTo("id", id).findAll().deleteAllFromRealm()
        }
    }

    // 모든 일정 삭제
    fun deleteAllSchedule() {
        realm.executeTransaction {
            it.where<SavedShift>().findAll().deleteAllFromRealm()
        }
    }

    // id max 값 + 1 반환하는 메소드
    fun getNextScheduleId(): Int {
        val maxId = realm.where<SavedShift>()
            .max("id")
        if (maxId != null) {
            return maxId.toInt() + 1
        }
        return 0
    }

}