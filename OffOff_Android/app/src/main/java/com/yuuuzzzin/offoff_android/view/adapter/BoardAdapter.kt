package com.yuuuzzzin.offoff_android.view.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostPreviewBinding
import com.yuuuzzzin.offoff_android.service.models.PostPreview

/*
* BoardActivity의 게시물 목록을 보여주는
* RecyclerView를 위한 Adapter
*/

class BoardAdapter(
    private val itemClick: (PostPreview) -> Unit,
) :
    ListAdapter<PostPreview, BoardAdapter.ViewHolder>(diffUtil) {

    /*
    * DiffUtil의 ItemCallback을 이용해
    * 갱신 전 데이터와 갱신 후 데이터의 차이점을 계산해
    * 효율적으로 업데이트
    * */

    private var onItemClickListener: OnItemClickListener? = null

    interface OnItemClickListener{
        fun onItemClick(postPreview: PostPreview)
    }

    fun setItemClickListener(listener: OnItemClickListener){
        onItemClickListener = listener
    }

    /* (뷰가 생성될 때) 레이아웃 생성 */
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding: RvItemPostPreviewBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_post_preview,
            parent,
            false
        )

        return ViewHolder(binding)
    }

    /* (뷰가 재활용될 때) 뷰홀더가 뷰에 그려졌을 때 데이터를 바인드해주는 함수 */
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    /* 넣고자 하는 데이터를 실제 레이아웃의 데이터로 연결 */
    inner class ViewHolder(private val binding: RvItemPostPreviewBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(
            postPreview: PostPreview
        ) {
            binding.postPreview = postPreview
            binding.root.setOnClickListener {
                itemClick(postPreview)
            }
        }
    }

    companion object {

        val diffUtil = object : DiffUtil.ItemCallback<PostPreview>() {

            // 두 아이템이 동일한 아이템인가? (id 기준 비교)
            override fun areItemsTheSame(oldItem: PostPreview, newItem: PostPreview): Boolean {
                return oldItem.id == newItem.id
            }

            // 두 아이템이 동일한 내용을 가지는가?
            override fun areContentsTheSame(oldItem: PostPreview, newItem: PostPreview): Boolean {
                return newItem == oldItem
            }
        }
    }
}