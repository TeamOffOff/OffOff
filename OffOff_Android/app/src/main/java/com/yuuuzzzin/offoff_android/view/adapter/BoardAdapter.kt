package com.yuuuzzzin.offoff_android.view.adapter

import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostPreviewBinding
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.base.BaseRVAdapter

/*
* BoardActivity의 게시물 목록을 보여주는
* RecyclerView를 위한 Adapter
*/

class BoardAdapter(
    itemClick: (Post) -> Unit
) : BaseRVAdapter<Post, RvItemPostPreviewBinding>(itemClick, R.layout.rv_item_post_preview)