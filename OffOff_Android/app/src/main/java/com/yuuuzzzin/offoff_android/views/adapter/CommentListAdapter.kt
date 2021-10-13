package com.yuuuzzzin.offoff_android.views.adapter

import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemCommentBinding
import com.yuuuzzzin.offoff_android.service.models.Comment
import com.yuuuzzzin.offoff_android.utils.base.BaseRVAdapter

class CommentListAdapter(
    itemClick: (Comment) -> Unit
) : BaseRVAdapter<Comment, RvItemCommentBinding>(itemClick, R.layout.rv_item_comment)