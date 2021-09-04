package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.RvItemScehduleTypeSettingBinding
import com.yuuuzzzin.offoff_android.views.adapter.ScheduleTypeSettingListAdapter.ScheduleTypeSettingListViewHolder

class ScheduleTypeSettingListAdapter() : RecyclerView.Adapter<ScheduleTypeSettingListViewHolder>() {

    lateinit var binding: RvItemScehduleTypeSettingBinding

    var shiftList = mutableListOf<Shift>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ScheduleTypeSettingListViewHolder {
        binding = RvItemScehduleTypeSettingBinding.inflate(LayoutInflater.from(parent.context), parent, false)

        return ScheduleTypeSettingListViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ScheduleTypeSettingListViewHolder, position: Int) {
        holder.onBind(shiftList[position])
    }

    override fun getItemCount(): Int {
        return shiftList.size
    }

    inner class ScheduleTypeSettingListViewHolder(private val binding : RvItemScehduleTypeSettingBinding) : RecyclerView.ViewHolder(binding.root) {
        fun onBind(shift: Shift) {
            binding.tvName.text = shift.title
            binding.tvTime.text = shift.startDate.toString() + " - " + shift.endDate.toString()
        }
    }
}