package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemCommentBinding
import com.yuuuzzzin.offoff_android.service.models.Comment

class CommentListAdapter:
    ListAdapter<Comment, CommentListAdapter.ViewHolder>(diffCallback) {

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

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding: RvItemCommentBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_comment,
            parent,
            false
        )

        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(
        private val binding: RvItemCommentBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Comment) {
            binding.setVariable(BR.item, item)
            binding.executePendingBindings()
            binding.btLikes.setOnClickListener {
                likeCommentListener.onLikeComment(adapterPosition, item)
            }
        }
    }
}