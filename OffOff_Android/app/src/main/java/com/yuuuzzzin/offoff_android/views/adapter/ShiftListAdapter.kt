package com.yuuuzzzin.offoff_android.views.adapter

import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.RvItemBoardBinding
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.utils.base.BaseRVAdapter

class ShiftListAdapter (
    itemClick = null
) : BaseRVAdapter<Shift, RvItemBoardBinding>(itemClick, R.layout.rv_item_shift)
}