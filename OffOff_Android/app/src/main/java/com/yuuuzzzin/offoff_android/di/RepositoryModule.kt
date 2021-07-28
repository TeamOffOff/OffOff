package com.yuuuzzzin.offoff_android.di

import com.yuuuzzzin.offoff_android.service.api.AuthService
import com.yuuuzzzin.offoff_android.service.api.BoardService
import com.yuuuzzzin.offoff_android.service.repository.AuthRepository
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
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
    fun provideAuthRepository(authService: AuthService): AuthRepository {
        return AuthRepository(authService)
    }

}