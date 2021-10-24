package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemCommentBinding
import com.yuuuzzzin.offoff_android.service.models.Comment
import com.yuuuzzzin.offoff_android.service.models.Reply

class CommentListAdapter :
    ListAdapter<Comment, CommentListAdapter.CommentViewHolder>(diffCallback) {

    companion object {
        private val diffCallback = object : DiffUtil.ItemCallback<Comment>() {
            // 두 아이템이 동일한 아이템인가? (identifier 기준 비교)
            override fun areItemsTheSame(oldItem: Comment, newItem: Comment): Boolean {
                return oldItem.id == newItem.id
            }

            // 두 아이템이 동일한 내용을 가지는가?
            override fun areContentsTheSame(oldItem: Comment, newItem: Comment): Boolean {
                return oldItem == newItem
            }
        }
    }

    interface OnLikeCommentListener {
        fun onLikeComment(position: Int, comment: Comment)
    }

    private lateinit var likeCommentListener: OnLikeCommentListener

    fun setOnLikeCommentListener(listener: OnLikeCommentListener) {
        this.likeCommentListener = listener
    }

    interface OnClickCommentOptionListener {
        fun onClickCommentOption(comment: Comment)
    }

    private lateinit var clickCommentOptionListener: OnClickCommentOptionListener

    fun setOnClickCommentOptionListener(listener: OnClickCommentOptionListener) {
        this.clickCommentOptionListener = listener
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CommentViewHolder {
        val binding: RvItemCommentBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_comment,
            parent,
            false
        )

        return CommentViewHolder(binding)
    }

    override fun onBindViewHolder(holder: CommentViewHolder, position: Int) {
        holder.bind(getItem(position), position)
    }

    inner class CommentViewHolder(
        private val binding: RvItemCommentBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Comment, position: Int) {
            binding.setVariable(BR.item, item)
            binding.executePendingBindings()
            binding.btLikes.setOnClickListener {
                likeCommentListener.onLikeComment(position, item)
            }
            if(item.childrenReplies != null) {
                val replyListAdapter = ReplyListAdapter()
                replyListAdapter.replyList = item.childrenReplies as ArrayList<Reply>
                replyListAdapter.notifyDataSetChanged()
                binding.rvReply.adapter = replyListAdapter
                binding.rvReply.layoutManager = LinearLayoutManager(binding.root.context)
            }
            binding.btCommentOption.setOnClickListener {
                clickCommentOptionListener.onClickCommentOption(item)
            }
        }
    }
}