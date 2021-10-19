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

    private val commentList: MutableList<Comment> = mutableListOf()

    interface OnLikeCommentListener {
        fun onLikeComment(position: Int, comment: Comment)
    }

    private lateinit var likeCommentListener: OnLikeCommentListener

    fun setOnLikeCommentListener(listener: OnLikeCommentListener) {
        this.likeCommentListener = listener
    }

    interface OnDeleteCommentListener {
        fun onDeleteComment(position: Int, comment: Comment)
    }

    private lateinit var deleteCommentListener: OnDeleteCommentListener

    fun setOnDeleteCommentListener(listener: OnDeleteCommentListener) {
        this.deleteCommentListener = listener
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

        lateinit var comment: Comment

        fun bind(item: Comment, position: Int) {
            comment = item
            binding.setVariable(BR.item, comment)
            binding.executePendingBindings()
            binding.btLikes.setOnClickListener {
                likeCommentListener.onLikeComment(position, item)
            }
//            binding.btCommentOption.setOnClickListener {
//                if(OffoffApplication.user.id == comment.value!!.author.id) {
//                    viewModel.showMyCommentDialog(comment.value!!.id)
//                } else {
//                    viewModel.showCommentDialog(comment.value!!.id)
//                }
//            }

        }

    }

    fun updateComment(position: Int, comment: Comment) {
        currentList[position] = comment
        notifyItemChanged(position)
    }

    private fun findItemPosById(id: String): Int {
        return currentList.indexOfFirst { it.id == id }
    }

}