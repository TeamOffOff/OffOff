package com.yuuuzzzin.offoff_android.service.repository

import com.yuuuzzzin.offoff_android.service.api.BoardService
import com.yuuuzzzin.offoff_android.service.models.CommentSend
import com.yuuuzzzin.offoff_android.service.models.PostSend
import javax.inject.Inject

/* 게시판 Repository */

class BoardRepository
@Inject
constructor(private val boardService: BoardService) {

    suspend fun getBoardList() = boardService.getBoardList()
    suspend fun getPosts(boardType: String) = boardService.getPosts(boardType)
    suspend fun getPost(auth: String, postId: String, boardType: String) =
        boardService.getPost(auth, postId, boardType)

    suspend fun writePost(auth: String, post: PostSend) = boardService.writePost(auth, post)
    suspend fun editPost(post: PostSend) = boardService.editPost(post)
    suspend fun deletePost(post: PostSend) = boardService.deletePost(post)

    suspend fun getComment(postId: String, boardType: String) = boardService.getComment(postId, boardType)
    suspend fun writeComment(comment: CommentSend) = boardService.writeComment(comment)
}
