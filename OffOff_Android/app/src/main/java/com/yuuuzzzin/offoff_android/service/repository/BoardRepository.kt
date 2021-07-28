package com.yuuuzzzin.offoff_android.service.repository

import com.yuuuzzzin.offoff_android.service.api.BoardService
import javax.inject.Inject

/* 게시판 Repository */

class BoardRepository

@Inject
constructor(private val boardService: BoardService) {

    suspend fun getPosts() = boardService.getPosts()
    suspend fun getPost(postId: String, postBoardType: String) =
        boardService.getPost(postId, postBoardType)
}
