package com.yuuuzzzin.offoff_android.di

import com.yuuuzzzin.offoff_android.service.api.BoardService
import com.yuuuzzzin.offoff_android.service.api.MemberService
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.service.repository.MemberRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ViewModelComponent
import dagger.hilt.android.scopes.ViewModelScoped

@Module
@InstallIn(ViewModelComponent::class)
object RepositoryModule {

    @Provides
    @ViewModelScoped
    fun provideBoardRepository(boardService: BoardService): BoardRepository {
        return BoardRepository(boardService)
    }

    @Provides
    @ViewModelScoped
    fun provideMemberRepository(memberService: MemberService): MemberRepository {
        return MemberRepository(memberService)
    }

//    @Provides
//    @ViewModelScoped
//    fun provideScheduleServiceRepository(shiftDao: ShiftDao): ScheduleServiceRepository {
//        return ScheduleServiceRepository(shiftDao)
//    }

}