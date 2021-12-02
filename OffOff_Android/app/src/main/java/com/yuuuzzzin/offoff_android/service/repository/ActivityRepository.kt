package com.yuuuzzzin.offoff_android.service.repository

import com.yuuuzzzin.offoff_android.service.api.ActivityService
import javax.inject.Inject

class ActivityRepository
@Inject
constructor(private val activityService: ActivityService) {

    suspend fun getMyLikeList(auth: String) = activityService.getMyLikeList(auth)
    suspend fun getMyPostList(auth: String) = activityService.getMyPostList(auth)
    suspend fun getMyReportPostList(auth: String) = activityService.getMyReportPostList(auth)
    suspend fun getMyBookmarkPostList(auth: String) = activityService.getMyBookmarkPostList(auth)
    suspend fun getMyCommentPostList(auth: String) = activityService.getMyCommentPostList(auth)
}