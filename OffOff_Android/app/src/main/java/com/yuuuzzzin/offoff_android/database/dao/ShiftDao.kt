package com.yuuuzzzin.offoff_android.database.dao

import com.yuuuzzzin.offoff_android.database.asLiveData
import com.yuuuzzzin.offoff_android.database.models.Shift
import io.realm.Realm
import io.realm.kotlin.where

/* 리포지토리에서 접근할 ShiftDao 클래스 */

class ShiftDao(private val realm: Realm) {

    // 모든 근무타입 가져오기
    fun getAllShifts() = realm.where<Shift>()
        .findAllAsync()
        .asLiveData()

    // 근무타입 추가
   fun insertShift(shift: Shift) {
        realm.executeTransactionAsync {
            it.insert(shift)
        }
    }

    // 특정 근무타입 삭제
//    fun deleteShift(id: String) {
//        realm.executeTransaction {
//            it.where<Shift>().equalTo("shift", id).findAll().deleteAllFromRealm()
//        }
//    }

    // 모든 근무타입 삭제
    fun deleteAllShifts() {
        realm.executeTransaction {
            it.where<Shift>().findAll().deleteAllFromRealm()
        }
    }

}