package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemReplyBinding
import com.yuuuzzzin.offoff_android.service.models.Reply

class ReplyListAdapter
    : RecyclerView.Adapter<ReplyListAdapter.ReplyViewHolder>() {

    interface OnReplyClickListener {
        fun onClickOption(item: Reply, position: Int)
    }

    private lateinit var replyClickListener: OnReplyClickListener

    fun setOnReplyClickListener(listener: OnReplyClickListener) {
        this.replyClickListener = listener
    }

    var replyList = ArrayList<Reply>()

    override fun getItemCount(): Int = replyList.size

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): ReplyListAdapter.ReplyViewHolder {
        val binding: RvItemReplyBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_reply,
            parent,
            false
        )

        return ReplyViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ReplyListAdapter.ReplyViewHolder, position: Int) {
        holder.bind(replyList[position], position)
    }

    inner class ReplyViewHolder(
        private val binding: RvItemReplyBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Reply, position: Int) {
            binding.setVariable(BR.item, item)
            binding.btCommentOption.setOnClickListener {
                replyClickListener.onClickOption(item, position)
            }
            binding.executePendingBindings()
        }

    }

}