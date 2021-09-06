package com.yuuuzzzin.offoff_android.database.models

import io.realm.RealmObject
import io.realm.annotations.PrimaryKey

/* Realm 데이터 클래스 */

open class Shift  (
    @PrimaryKey
    var id: Int? = 0,
    var title: String? = null,
    var textColor: Int? = null,
    var backgroundColor: Int? = null,
    var startDate: String? = null,
    var endDate: String? = null
) : RealmObject()

open class SavedShift(
    @PrimaryKey
    var id: Int? = 0,
    var date: String? = null,
    var shift: Shift? = null
) : RealmObject()