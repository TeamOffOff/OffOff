package com.yuuuzzzin.offoff_android.views.adapter

import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemBoardBinding
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.utils.base.BaseListAdapter

/*
* BoardActivity의 게시물 목록을 보여주는
* RecyclerView를 위한 Adapter
*/

class BoardListAdapter(
    itemClick: (Board) -> Unit
) : BaseListAdapter<Board, RvItemBoardBinding>(itemClick, R.layout.rv_item_board)