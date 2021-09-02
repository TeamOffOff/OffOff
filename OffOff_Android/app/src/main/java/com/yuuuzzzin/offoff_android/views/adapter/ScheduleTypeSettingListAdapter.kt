package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.RvItemScehduleTypeSettingBinding
import com.yuuuzzzin.offoff_android.proto.models.ScheduleType
import com.yuuuzzzin.offoff_android.views.adapter.ScheduleTypeSettingListAdapter.ScheduleTypeSettingListViewHolder
import io.realm.OrderedRealmCollection
import io.realm.RealmRecyclerViewAdapter

class ScheduleTypeSettingListAdapter internal constructor(
    data: OrderedRealmCollection<Shift>,
    autoUpdate: Boolean = true,
    private val click: (String) -> Unit
) : RealmRecyclerViewAdapter<Shift, ScheduleTypeSettingListViewHolder>(data, autoUpdate) {

    lateinit var binding: RvItemScehduleTypeSettingBinding

    private var scheduleTypeList = mutableListOf<ScheduleType>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ScheduleTypeSettingListViewHolder {
        binding = RvItemScehduleTypeSettingBinding.inflate(LayoutInflater.from(parent.context), parent, false)

        return ScheduleTypeSettingListViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ScheduleTypeSettingListViewHolder, position: Int) {
        holder.onBind(scheduleTypeList[position])
    }

    override fun getItemCount(): Int {
        return scheduleTypeList.size
    }

    inner class ScheduleTypeSettingListViewHolder(private val binding : RvItemScehduleTypeSettingBinding) : RecyclerView.ViewHolder(binding.root) {
        fun onBind(scheduleType: ScheduleType) {
            binding.tvName.text = scheduleType.name
            binding.tvTime.text = scheduleType.startTime.toString() + " - " + scheduleType.endTime.toString()
        }
    }
}