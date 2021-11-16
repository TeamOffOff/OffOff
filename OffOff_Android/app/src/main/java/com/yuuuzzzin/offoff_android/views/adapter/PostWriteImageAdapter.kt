package com.yuuuzzzin.offoff_android.views.adapter

import android.net.Uri
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemPostWriteImageBinding
import com.yuuuzzzin.offoff_android.service.models.Image

class PostWriteImageAdapter :
    RecyclerView.Adapter<PostWriteImageAdapter.PostWriteImageViewHolder>() {

    private var imageList = ArrayList<Uri>()
    private var images = ArrayList<Image>()

    override fun getItemCount(): Int = imageList.size

    interface OnPostWriteImageClickListener {
        fun onClickBtDelete(position: Int)
    }

    private lateinit var postWriteImageClickListener: OnPostWriteImageClickListener

    fun setOnPostWriteImageClickListener(listener: OnPostWriteImageClickListener) {
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

        fun bind(uri: Uri, position: Int) {
            //binding.setVariable(BR.item, uri))
            //images.add()
            binding.ivImage.apply {
                setImageURI(uri)
                clipToOutline = true
            }
            binding.executePendingBindings()
            binding.btDelete.setOnClickListener {
                postWriteImageClickListener.onClickBtDelete(position)
            }
        }
    }

    fun clearItems() {
        this.imageList.clear()
        notifyDataSetChanged()
    }

    fun addItem(uri: Uri) {
        // this.imageList.clear()
        this.imageList.add(uri)
        notifyDataSetChanged()
    }

    fun removeItem(position: Int) {
        imageList.removeAt(position)
        notifyDataSetChanged()
    }

    fun addItems(items: List<Uri>) {
        this.imageList.addAll(items)
        notifyDataSetChanged()
    }

    fun getItems(): List<Uri> {
        return this.imageList
    }

    fun updateItem(uri: Uri, position: Int) {
        imageList[position] = uri
        notifyItemChanged(position)
    }

}