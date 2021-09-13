package com.yuuuzzzin.offoff_android.views.adapter

import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.RvItemShiftBinding

class ShiftListAdapter() : RecyclerView.Adapter<ShiftListAdapter.ViewHolder>() {

    lateinit var binding: RvItemShiftBinding
    private lateinit var shiftList: List<Shift>

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        binding = RvItemShiftBinding.inflate(LayoutInflater.from(parent.context), parent, false)

        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(shiftList[position])
    }

    override fun getItemCount(): Int {
        return shiftList.count()
    }

    /*리사이클러뷰 아이템 내 메뉴 click listener 정의*/
    interface OnShiftMenuClickListener {
        fun onShiftMenuClick(view: View, shift: Shift)
    }

    private lateinit var shiftMenuClickListener: OnShiftMenuClickListener

    fun setOnShiftMenuClickListener(listener: OnShiftMenuClickListener) {
        this.shiftMenuClickListener = listener
    }

    inner class ViewHolder(private val binding: RvItemShiftBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(shift: Shift) {
            binding.iconTitle.text = shift.title
            binding.iconTitle.setTextColor(Color.parseColor(shift.textColor!!))
            binding.iconTitle.setBackgroundColor(
                Color.parseColor(shift.backgroundColor!!))
            binding.tvTime.text = shift.startTime.toString() + " - " + shift.endTime.toString()
            binding.btMenu.setOnClickListener {
                shiftMenuClickListener.onShiftMenuClick(binding.btMenu, shift)
            }
        }
    }

    fun updateList(list: List<Shift>) {
        shiftList = list
        notifyDataSetChanged()
    }

}