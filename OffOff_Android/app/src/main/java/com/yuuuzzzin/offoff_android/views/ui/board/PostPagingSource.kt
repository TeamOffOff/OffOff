package com.yuuuzzzin.offoff_android.views.ui.board

import androidx.paging.PagingSource
import androidx.paging.PagingState
import com.yuuuzzzin.offoff_android.service.api.BoardService
import com.yuuuzzzin.offoff_android.service.models.Post
import retrofit2.HttpException
import java.io.IOException
import javax.inject.Inject

class PostPagingSource
@Inject
constructor(
    private val boardService: BoardService,
    private val boardType: String
) : PagingSource<Int, Post>() {

    override suspend fun load(params: LoadParams<Int>): LoadResult<Int, Post> {
        val next = params.key ?: 0

        return try {
            val response = boardService.getPosts(boardType)

            LoadResult.Page(
                data = response.body()!!.postList,
                prevKey = if (next == 0) null else next - 1,
                nextKey = next + 1
            )
        } catch (exception: IOException) {
            LoadResult.Error(exception)
        } catch (exception: HttpException) {
            LoadResult.Error(exception)
        } catch (e: Exception) {
            LoadResult.Error(e)
        }
    }

    override fun getRefreshKey(state: PagingState<Int, Post>): Int? {
        return state.anchorPosition?.let { anchorPosition ->
            state.closestPageToPosition(
                anchorPosition
            )?.prevKey?.plus(1)
                ?: state.closestPageToPosition(anchorPosition)?.nextKey?.minus(1)
        }
    }
}