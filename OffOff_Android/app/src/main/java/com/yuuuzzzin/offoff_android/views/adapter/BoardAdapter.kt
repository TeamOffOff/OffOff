package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostPreviewBinding
import com.yuuuzzzin.offoff_android.service.models.Post
import java.lang.Boolean.TRUE

/*
* BoardActivity의 게시물 목록을 보여주는
* RecyclerView를 위한 Adapter
*/

class BoardAdapter :
    RecyclerView.Adapter<BoardAdapter.PostViewHolder>() {

    private var postList = ArrayList<Post>()

    override fun getItemCount(): Int = postList.size

    interface OnPostClickListener {
        fun onClickPost(item: Post, position: Int)
    }

    private lateinit var postClickListener: OnPostClickListener

    fun setOnPostClickListener(listener: OnPostClickListener) {
        this.postClickListener = listener
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BoardAdapter.PostViewHolder {
        val binding: RvItemPostPreviewBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_post_preview,
            parent,
            false
        )

        return PostViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PostViewHolder, position: Int) {
        holder.bind(postList[position], position)
    }

    inner class PostViewHolder(
        private val binding: RvItemPostPreviewBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Post, position: Int) {
            binding.setVariable(BR.item, item)
            binding.executePendingBindings()
            binding.root.setOnClickListener {
                postClickListener.onClickPost(item, position)
            }
        }
    }

    fun clearPostList() {
        this.postList.clear()
        notifyDataSetChanged()
    }

    fun addPostList(postList: List<Post>, isFirst: Boolean) {
        if (isFirst == TRUE) {
            this.postList.clear()
        }
        this.postList.addAll(postList)
        notifyDataSetChanged()
    }

    fun updateItem(post: Post, position: Int) {
        postList[position] = post
        notifyItemChanged(position)
    }

}