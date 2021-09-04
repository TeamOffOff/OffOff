package com.yuuuzzzin.offoff_android.di

import com.yuuuzzzin.offoff_android.database.dao.ShiftDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import io.realm.Realm
import javax.inject.Singleton

/* 데이터베이스 모듈 */

@InstallIn(SingletonComponent::class)
@Module
object DatabaseModule {

    @Singleton
    @Provides
    //@Named("realm")
    fun provideRealm() = Realm.getDefaultInstance()

    @Singleton
    @Provides
    fun provideShiftDao(realm: Realm) = ShiftDao(realm)
}
