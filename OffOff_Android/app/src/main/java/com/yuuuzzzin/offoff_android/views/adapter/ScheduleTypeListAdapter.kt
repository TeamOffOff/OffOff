package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.databinding.RvItemScheduleTypeBinding
import com.yuuuzzzin.offoff_android.proto.models.ScheduleType

class ScheduleTypeListAdapter() : RecyclerView.Adapter<ScheduleTypeListAdapter.ScheduleTypeListViewHolder>() {

    lateinit var binding: RvItemScheduleTypeBinding

    var scheduleTypeList = mutableListOf<ScheduleType>()

    // 어떤 View를 생성할 것인지
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ScheduleTypeListViewHolder {
        binding = RvItemScheduleTypeBinding.inflate(LayoutInflater.from(parent.context), parent, false)

        return ScheduleTypeListViewHolder(binding)
    }

    // 생성된 View에 어떤 데이터를 넣을 것인지
    override fun onBindViewHolder(holder: ScheduleTypeListViewHolder, position: Int) {
        holder.onBind(scheduleTypeList[position])
    }

    // 몇 개의 목록을 만들 것인지
    override fun getItemCount(): Int {
        return scheduleTypeList.size
    }

    /*리사이클러뷰 아이템 click listener 정의*/
    interface OnScheduleTypeClickListener {
        fun onScheduleTypeClick(view: View, scheduleType: ScheduleType)
    }

    private lateinit var scheduleTypeClickListener: OnScheduleTypeClickListener

    fun setOnScheduleTypeClickListener(listener: OnScheduleTypeClickListener) {
        this.scheduleTypeClickListener = listener
    }

    // 리스트의 개별 항목 레이아웃을 포함하는 View 래퍼로, 각 목록 레이아웃에 필요한 기능들을 구현하는 곳
    // ex) 아이템 레이아웃의 버튼이 있는 경우 버튼 리스너 Holer 클래스에서 구현
    // val 예약어로 binding을 전달 받아 전역으로 사용
    // 상속받는 ViewHolder 생성자에서는 꼭 binding.root를 전달해야 함.
    inner class ScheduleTypeListViewHolder(private val binding : RvItemScheduleTypeBinding) : RecyclerView.ViewHolder(binding.root) {
        fun onBind(scheduleType: ScheduleType) {
            binding.tvName.text = scheduleType.name
            itemView.setOnClickListener {
                scheduleTypeClickListener.onScheduleTypeClick(itemView, scheduleType)
            }
        }
    }
}