package com.yuuuzzzin.offoff_android.views.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.viewmodel.ScheduleViewModel

class ShiftListAdapter(): RecyclerView.Adapter<ShiftListAdapter.ViewHolder>() {

    private val shiftList = mutableListOf<Shift>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ShiftListAdapter.ViewHolder {
        return ViewHolder(parent)
    }

    override fun onBindViewHolder(holder: ShiftListAdapter.ViewHolder, position: Int) {
        TODO("Not yet implemented")
    }

    override fun getItemCount(): Int {
        TODO("Not yet implemented")
    }

    class ViewHolder {

    }
}