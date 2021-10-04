package com.yuuuzzzin.offoff_android.database.models

import io.realm.RealmObject
import io.realm.annotations.PrimaryKey

/* Realm 데이터 클래스 */

open class Shift  (
    @PrimaryKey
    var id: Int? = 0,
    var title: String? = null,
    var textColor: String? = null,
    var backgroundColor: String? = null,
    var startTime: String? = null,
    var endTime: String? = null
) : RealmObject()

open class SavedShift(
    @PrimaryKey
    var id: Int? = 0,
    var date: String? = null,
    var shift: Shift? = null
) : RealmObject()