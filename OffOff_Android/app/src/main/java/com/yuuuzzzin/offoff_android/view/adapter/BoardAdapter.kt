package com.yuuuzzzin.offoff_android.view.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostPreviewBinding
import com.yuuuzzzin.offoff_android.service.models.PostPreview

/*
* BoardActivity의 게시물 목록을 보여주는
* RecyclerView를 위한 Adapter
*/

class BoardAdapter :
    RecyclerView.Adapter<BoardAdapter.BoardViewHolder>() {

    /*
    * DiffUtil의 ItemCallback을 이용해
    * 갱신 전 데이터와 갱신 후 데이터의 차이점을 계산해
    * 효율적으로 업데이트
    * */
    private val diffCallback = object: DiffUtil.ItemCallback<PostPreview>() {

        // 두 아이템이 동일한 아이템인가? (id 기준 비교)
        override fun areItemsTheSame(oldItem: PostPreview, newItem: PostPreview): Boolean {
            return oldItem.id == newItem.id
        }

        // 두 아이템이 동일한 내용을 가지는가?
        override fun areContentsTheSame(oldItem: PostPreview, newItem: PostPreview): Boolean {
            return newItem == oldItem
        }
    }

    private val differ = AsyncListDiffer(this, diffCallback)
    var posts: List<PostPreview>
        get() = differ.currentList
        set(value) {
            differ.submitList(value)
        }

    /* 아이템의 개수 계산 -> 몇 개의 목록을 만들 것인지 */
    override fun getItemCount() = posts.size

    /* (뷰가 생성될 때) 레이아웃 생성 */
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BoardViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.rv_item_post_preview, parent, false)

        return BoardViewHolder(view)
    }

    /* (뷰가 재활용될 때) 뷰홀더가 뷰에 그려졌을 때 데이터를 바인드해주는 함수 */
    override fun onBindViewHolder(holder: BoardViewHolder, position: Int) {
        val currentPost = posts[position]
        holder.setPostPreview(currentPost, listener)
    }

    /* 넣고자 하는 데이터를 실제 레이아웃의 데이터로 연결 */
    inner class BoardViewHolder (itemView: View) : RecyclerView.ViewHolder(itemView) {
        private lateinit var binding: RvItemPostPreviewBinding

        fun setPostPreview(
            currentPost: PostPreview,
            listener: OnItemClickListener?
        ) {
            binding = RvItemPostPreviewBinding.bind(itemView)
            binding.apply {
                tvTitle.text = currentPost.metadataPreview.title
                tvContentPreview.text = currentPost.contents.content
                tvDate.text = currentPost.metadataPreview.date
                tvAuthor.text = currentPost.metadataPreview.author
                tvLikes.text = (currentPost.metadataPreview.likes).toString()
                tvReplyCount.text = (currentPost.metadataPreview.reply_count).toString()

                itemView.setOnClickListener {
                    listener?.onItemClick(itemView, currentPost)
                }
            }
        }
    }

    // 리사이클러뷰 아이템 클릭시 다른 Activity로 이동하기 위한 ClickListener 정의
    interface OnItemClickListener {
        fun onItemClick(view: View, postPreview: PostPreview)
    }

    private var listener: OnItemClickListener? = null

    fun setOnItemClickListener(listener: OnItemClickListener) {
        this.listener = listener
    }

}