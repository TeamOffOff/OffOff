package com.yuuuzzzin.offoff_android.database

import androidx.lifecycle.LiveData
import io.realm.RealmChangeListener
import io.realm.RealmModel
import io.realm.RealmResults

/* LiveData와 Realm을 연동하기 위한 Class */

class RealmLiveData<T: RealmModel>(
    private val realmResults: RealmResults<T>
) : LiveData<RealmResults<T>>() {

    private val listener = RealmChangeListener<RealmResults<T>> {
        value = it
    }

    override fun onActive() {
        realmResults.addChangeListener(listener)
    }

    override fun onInactive() {
        realmResults.removeChangeListener(listener)
    }
}

/* RealmResult를 RealmLiveData 형식으로 바꿈 */
fun <T : RealmModel> RealmResults<T>.asLiveData() = RealmLiveData(this)