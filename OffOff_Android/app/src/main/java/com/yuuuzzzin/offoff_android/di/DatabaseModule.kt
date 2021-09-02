package com.yuuuzzzin.offoff_android.di

/* 데이터베이스 모듈 */

//@InstallIn(SingletonComponent::class)
//@Module
//class DatabaseModule {
//
//    @Singleton
//    @Provides
//    fun provideRealm(
//        @ApplicationContext context: Context
//    ): Realm {
//        Realm.init(context)
//        val realmConfiguration = RealmConfiguration
//            .Builder()
//            .name("schedule.realm")
//            .allowWritesOnUiThread(true)
//            .build()
//        Realm.setDefaultConfiguration(realmConfiguration)
//        return Realm.getDefaultInstance()
//    }
//
//    private fun provideRealmConfig(): RealmConfiguration = RealmConfiguration.Builder().build()
//}
