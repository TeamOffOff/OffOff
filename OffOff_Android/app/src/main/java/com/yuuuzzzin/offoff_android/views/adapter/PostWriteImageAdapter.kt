package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostWriteImageBinding
import com.yuuuzzzin.offoff_android.service.models.Image

class PostWriteImageAdapter :
    RecyclerView.Adapter<PostWriteImageAdapter.PostWriteImageViewHolder>() {

    private var imageList = ArrayList<Image>()

    override fun getItemCount(): Int = imageList.size

    interface OnPostWriteImageClickListener {
        fun onClickPostWriteImage(item: Image, position: Int)
    }

    private lateinit var postWriteImageClickListener: PostWriteImageAdapter.OnPostWriteImageClickListener

    fun setOnPostWriteImageClickListener(listener: PostWriteImageAdapter.OnPostWriteImageClickListener) {
        this.postWriteImageClickListener = listener
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): PostWriteImageAdapter.PostWriteImageViewHolder {
        val binding: RvItemPostWriteImageBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_post_write_image,
            parent,
            false
        )

        return PostWriteImageViewHolder(binding)
    }

    override fun onBindViewHolder(
        holder: PostWriteImageAdapter.PostWriteImageViewHolder,
        position: Int
    ) {
        holder.bind(imageList[position], position)
    }

    inner class PostWriteImageViewHolder(
        private val binding: RvItemPostWriteImageBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Image, position: Int) {
            binding.setVariable(BR.item, item)
            binding.executePendingBindings()
            binding.ivImage.clipToOutline = true
            binding.root.setOnClickListener {
                postWriteImageClickListener.onClickPostWriteImage(item, position)
            }
        }
    }

    fun clearPostWriteImageList() {
        this.imageList.clear()
        notifyDataSetChanged()
    }

    fun addImage(image: Image) {
        // this.imageList.clear()
        this.imageList.add(image)
        notifyDataSetChanged()
    }

    fun updateItem(image: Image, position: Int) {
        imageList[position] = image
        notifyItemChanged(position)
    }

}