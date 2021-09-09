package com.yuuuzzzin.offoff_android.views.adapter

import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.RvItemShiftIconBinding

class ShiftIconListAdapter() : RecyclerView.Adapter<ShiftIconListAdapter.ViewHolder>() {

    lateinit var binding: RvItemShiftIconBinding
    private lateinit var shiftList: List<Shift>

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        binding = RvItemShiftIconBinding.inflate(LayoutInflater.from(parent.context), parent, false)

        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(shiftList[position])
    }

    override fun getItemCount(): Int {
        return shiftList.count()
    }

    /*리사이클러뷰 아이템 click listener 정의*/
    interface OnShiftIconClickListener {
        fun onShiftIconClick(view: View, shift: Shift)
    }

    private lateinit var shiftIconClickListener: OnShiftIconClickListener

    fun setOnScheduleTypeClickListener(listener: OnShiftIconClickListener) {
        this.shiftIconClickListener = listener
    }

    inner class ViewHolder(private val binding: RvItemShiftIconBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(shift: Shift) {
            binding.iconTitle.text = shift.title
            binding.iconTitle.setTextColor(Color.parseColor(shift.textColor!!))
            binding.iconTitle.setBackgroundColor(Color.parseColor(shift.backgroundColor!!))
            itemView.setOnClickListener {
                shiftIconClickListener.onShiftIconClick(itemView, shift)
            }
        }
    }

    fun updateList(list: List<Shift>) {
        shiftList = list
        notifyDataSetChanged()
    }
}