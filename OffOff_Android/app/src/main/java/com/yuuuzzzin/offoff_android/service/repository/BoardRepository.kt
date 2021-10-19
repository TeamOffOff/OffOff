package com.yuuuzzzin.offoff_android.service.repository

import com.yuuuzzzin.offoff_android.service.api.BoardService
import com.yuuuzzzin.offoff_android.service.models.ActivityItem
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
    suspend fun editPost(auth: String, post: PostSend) = boardService.editPost(auth, post)
    suspend fun deletePost(auth: String, post: PostSend) = boardService.deletePost(auth, post)
    suspend fun doPostActivity(auth: String, activityItem: ActivityItem) = boardService.doPostActivity(auth, activityItem)

    suspend fun getComments(auth: String, postId: String, boardType: String) = boardService.getComments(auth, postId, boardType)
    suspend fun writeComment(auth: String, comment: CommentSend) = boardService.writeComment(auth, comment)
    suspend fun deleteComment(auth: String, comment: CommentSend) = boardService.deleteComment(auth, comment)
    suspend fun likeComment(auth: String, activityItem: ActivityItem) = boardService.likeComment(auth, activityItem)

}
