package com.yuuuzzzin.offoff_android.view.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostPreviewBinding
import com.yuuuzzzin.offoff_android.service.model.Post

class PostListAdapter :
    RecyclerView.Adapter<PostListAdapter.PostListHolder>() {
    var postList = mutableListOf<Post>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PostListHolder {

        // layout을 inflate한 후 holder에 담아서 반환
        // xml layout이 객체화되는 과정은 메모리에 로딩되어 화면(뷰 그룹)으로 드러나는데, 이 과정을 Inflation이라고 함.
        // 매개변수: inflate(1. 객체화하고 싶은 xml 파일, 2. 객체화한 뷰를 넣을 부모 레이아웃/컨테이너, 3. 바로 inflation하고자 하는지 여부)
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.rv_item_post_preview, parent, false)

        // PostPreviewListHolder에 view 변수를 담아서 반환
        return PostListHolder(view)
    }

    // 현 위치의 게시물 미리보기 데이터를 postList에서 가져옴
    override fun onBindViewHolder(holder: PostListHolder, position: Int) {
        // 현 위치의 게시물 미리보기 데이터를 postList에서 가져옴
        val post = postList.get(position)
        holder.setPostPreview(post, listener)
    }

    override fun getItemCount(): Int {
        return postList.size
    }

    // 리사이클러뷰 아이템 클릭시 PostActivity로 이동하기 위한 post click listener 정의
    interface OnItemClickListener {
        fun onItemClick(view: View, post: Post)
    }

    private var listener: OnItemClickListener? = null

    fun setOnItemClickListener(listener: OnItemClickListener) {
        this.listener = listener
    }

    // ViewHolder를 상속받고, 아이템뷰를 받는 처리
    inner class PostListHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private lateinit var binding: RvItemPostPreviewBinding

        fun setPostPreview(
            post: Post,
            listener: PostListAdapter.OnItemClickListener?
        ) {
            binding = RvItemPostPreviewBinding.bind(itemView)
            binding.tvTitle.text = post.metadata.title
            binding.tvContentPreview.text = post.contents.content
            binding.tvDate.text = post.metadata.date
            binding.tvAuthor.text = post.metadata.author
            binding.tvLikes.text = (post.metadata.likes).toString()
            binding.tvReplyCount.text = (post.metadata.reply_count).toString()

            itemView.setOnClickListener {
                listener?.onItemClick(itemView, post)
            }
        }

    }

}