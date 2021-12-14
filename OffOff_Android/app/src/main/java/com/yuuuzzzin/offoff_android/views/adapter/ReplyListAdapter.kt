package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemReplyBinding
import com.yuuuzzzin.offoff_android.service.models.Reply
import com.yuuuzzzin.offoff_android.utils.ImageUtils

class ReplyListAdapter(private val parentPosition: Int) :
    RecyclerView.Adapter<ReplyListAdapter.ReplyViewHolder>() {

    interface OnReplyClickListener {
        fun onClickOption(item: Reply, position: Int)
        fun onLikeReply(position: Int, parentPosition: Int, reply: Reply)
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
        holder.bind(replyList[position], position, parentPosition)
    }

    inner class ReplyViewHolder(
        private val binding: RvItemReplyBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Reply, position: Int, parentPosition: Int) {
            binding.setVariable(BR.item, item)
            if (!item.author!!.profileImage.isNullOrEmpty()) {
                binding.ivAvatar.apply {
                    setImageBitmap(ImageUtils.stringToBitmap(item.author.profileImage!![0].body.toString()))
                    clipToOutline = true
                }
            }
            binding.btReplyOption.setOnClickListener {
                replyClickListener.onClickOption(item, position)
            }
            binding.btLikes.setOnClickListener {
                replyClickListener.onLikeReply(position, parentPosition, item)
            }
            binding.executePendingBindings()
        }
    }

    fun addReplyList(replyList: List<Reply>) {
        this.replyList.clear()
        this.replyList.addAll(replyList)
        notifyDataSetChanged()
    }

    fun updateItem(reply: Reply, position: Int) {
        replyList[position] = reply
        notifyItemChanged(position)
    }
}