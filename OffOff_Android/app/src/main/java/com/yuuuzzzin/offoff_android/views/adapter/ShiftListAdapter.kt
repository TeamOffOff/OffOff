package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
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

    class ViewHolder(private val binding: RvItemShiftBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(shift: Shift) {
            binding.iconTitle.text = shift.title
            binding.iconTitle.setTextColor(shift.textColor!!)
            binding.iconTitle.setBackgroundColor(shift.backgroundColor!!)
            binding.tvTime.text = shift.startDate.toString() + " - " + shift.endDate.toString()
        }
    }

    fun updateList(list: List<Shift>) {
        shiftList = list
        notifyDataSetChanged()
    }
}