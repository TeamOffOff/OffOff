package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostImageBinding
import com.yuuuzzzin.offoff_android.service.models.Image
import com.yuuuzzzin.offoff_android.utils.ImageUtils.stringToBitmap

class PostImageAdapter :
    RecyclerView.Adapter<PostImageAdapter.PostImageViewHolder>() {

    private var imageList = ArrayList<Image>()

    override fun getItemCount(): Int = imageList.size

    interface OnPostImageClickListener {
        fun onClickPostImage(item: Image, position: Int)
    }

    private lateinit var postImageClickListener: OnPostImageClickListener

    fun setOnPostImageClickListener(listener: PostImageAdapter.OnPostImageClickListener) {
        this.postImageClickListener = listener
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): PostImageAdapter.PostImageViewHolder {
        val binding: RvItemPostImageBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_post_image,
            parent,
            false
        )

        return PostImageViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PostImageViewHolder, position: Int) {
        holder.bind(imageList[position], position)
    }

    inner class PostImageViewHolder(
        private val binding: RvItemPostImageBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Image, position: Int) {
            binding.setVariable(BR.item, item)
            binding.ivImage.apply {
                setImageBitmap(stringToBitmap(item.body.toString()))
                clipToOutline = true
            }
            binding.executePendingBindings()
            binding.root.setOnClickListener {
                postImageClickListener.onClickPostImage(item, position)
            }
        }
    }

    fun addPostImageList(imageList: List<Image>) {
        this.imageList.clear()
        this.imageList.addAll(imageList)
        notifyDataSetChanged()
    }

    fun updateItem(image: Image, position: Int) {
        imageList[position] = image
        notifyItemChanged(position)
    }

}