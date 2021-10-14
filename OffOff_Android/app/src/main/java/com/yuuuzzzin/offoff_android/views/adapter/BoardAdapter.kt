package com.yuuuzzzin.offoff_android.views.adapter

import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostPreviewBinding
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.base.BaseListAdapter

/*
* BoardActivity의 게시물 목록을 보여주는
* RecyclerView를 위한 Adapter
*/

class BoardAdapter(
    itemClick: (Post) -> Unit
) : BaseListAdapter<Post, RvItemPostPreviewBinding>(itemClick, R.layout.rv_item_post_preview)