package com.yuuuzzzin.offoff_android.di

import com.google.gson.GsonBuilder
import com.yuuuzzzin.offoff_android.BuildConfig
import com.yuuuzzzin.offoff_android.service.api.ActivityService
import com.yuuuzzzin.offoff_android.service.api.BoardService
import com.yuuuzzzin.offoff_android.service.api.MemberService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

/* 네트워크 통신을 위한 모듈 */

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    // private const val BASE_URL = "http:10.0.2.2:3000/" // 로컬 가상 서버 주소
    private const val BASE_URL = BuildConfig.BASE_URL

    /* Retrofit2 통신 모듈 */
    @Singleton
    @Provides
    fun provideRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(
                GsonConverterFactory.create(
                    GsonBuilder().serializeNulls().setLenient().create()
                )
            )
            .build()
    }

    /* Post 관련 API 를 위한 모듈 */
    @Singleton
    @Provides
    fun provideBoardService(retrofit: Retrofit): BoardService =
        retrofit.create(BoardService::class.java)

    /* 회원 관련 API 를 위한 모듈 */
    @Singleton
    @Provides
    fun provideMemberService(retrofit: Retrofit): MemberService =
        retrofit.create(MemberService::class.java)

    /* 회원 활동 관련 API 를 위한 모듈 */
    @Singleton
    @Provides
    fun provideActivityService(retrofit: Retrofit): ActivityService =
        retrofit.create(ActivityService::class.java)
}