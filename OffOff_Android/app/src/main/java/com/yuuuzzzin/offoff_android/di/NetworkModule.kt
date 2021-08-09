package com.yuuuzzzin.offoff_android.di

import com.yuuuzzzin.offoff_android.BuildConfig
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
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    /* Post API를 위한 모듈 */
    @Singleton
    @Provides
    fun provideBoardService(retrofit: Retrofit): BoardService =
        retrofit.create(BoardService::class.java)

    /* 로그인 응답을 위한 모듈 */
    @Singleton
    @Provides
    fun provideMemberService(retrofit: Retrofit): MemberService =
        retrofit.create(MemberService::class.java)

}