package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostPreviewBinding
import com.yuuuzzzin.offoff_android.service.models.Post

/*
* BoardActivity의 게시물 목록을 보여주는
* RecyclerView를 위한 Adapter
*/

class BoardAdapter :
    ListAdapter<Post, BoardAdapter.BoardViewHolder>(diffCallback) {

    companion object {
        private val diffCallback = object : DiffUtil.ItemCallback<Post>() {
            // 두 아이템이 동일한 아이템인가? (identifier 기준 비교)
            override fun areItemsTheSame(oldItem: Post, newItem: Post): Boolean {
                return oldItem.id == newItem.id
            }

            // 두 아이템이 동일한 내용을 가지는가?
            override fun areContentsTheSame(oldItem: Post, newItem: Post): Boolean {
                return oldItem == newItem
            }
        }
    }

    interface OnClickPostListener {
        fun onClickPost(position: Int, item: Post)
    }

    private lateinit var clickPostListener: OnClickPostListener

    fun setOnClickPostListener(listener: OnClickPostListener) {
        this.clickPostListener = listener
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BoardAdapter.BoardViewHolder {
        val binding: RvItemPostPreviewBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_post_preview,
            parent,
            false
        )

        return BoardViewHolder(binding)
    }

    override fun onBindViewHolder(holder: BoardViewHolder, position: Int) {
        holder.bind(getItem(position), position)
    }

    inner class BoardViewHolder(
        private val binding: RvItemPostPreviewBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Post, position: Int) {
            binding.setVariable(BR.item, item)
            binding.executePendingBindings()
            binding.root.setOnClickListener {
                clickPostListener.onClickPost(position, item)
            }
        }
    }
}