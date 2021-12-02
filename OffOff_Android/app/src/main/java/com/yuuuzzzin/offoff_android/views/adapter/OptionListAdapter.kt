package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.database.models.Option
import com.yuuuzzzin.offoff_android.databinding.RvItemOptionBinding

class OptionListAdapter(private val optionList: ArrayList<Option>) :
    RecyclerView.Adapter<OptionListAdapter.OptionViewHolder>() {

    override fun getItemCount(): Int = optionList.size

    interface OnOptionClickListener {
        fun onClickOption(item: Option, position: Int)
    }

    private lateinit var optionClickListener: OnOptionClickListener

    fun setOnOptionClickListener(listener: OnOptionClickListener) {
        this.optionClickListener = listener
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): OptionListAdapter.OptionViewHolder {
        val binding: RvItemOptionBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_option,
            parent,
            false
        )

        return OptionViewHolder(binding)
    }

    override fun onBindViewHolder(holder: OptionListAdapter.OptionViewHolder, position: Int) {
        holder.bind(optionList[position], position)
    }

    inner class OptionViewHolder(
        private val binding: RvItemOptionBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Option, position: Int) {
            binding.setVariable(BR.item, item)
            binding.executePendingBindings()
            binding.root.setOnClickListener {
                optionClickListener.onClickOption(item, position)
            }
        }
    }
}