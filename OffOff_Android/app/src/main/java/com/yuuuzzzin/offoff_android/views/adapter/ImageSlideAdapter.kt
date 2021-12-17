package com.yuuuzzzin.offoff_android.views.adapter

import android.util.Log
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ViewPagerItemImageBinding
import com.yuuuzzzin.offoff_android.service.models.Image
import com.yuuuzzzin.offoff_android.utils.ImageUtils.stringToBitmap

class ImageSlideAdapter(private val imgList: List<Image>) :
    RecyclerView.Adapter<ImageSlideAdapter.ImageSlideViewHolder>() {

    val imageList = imgList

    override fun getItemCount(): Int = imageList.size

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): ImageSlideAdapter.ImageSlideViewHolder {
        val binding: ViewPagerItemImageBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.view_pager_item_image,
            parent,
            false
        )

        return ImageSlideViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ImageSlideAdapter.ImageSlideViewHolder, position: Int) {
        Log.d("tag_onBindViewHolder", "$position 바인드")
        holder.bind(imageList[position], position)
    }

    inner class ImageSlideViewHolder(
        private val binding: ViewPagerItemImageBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Image, position: Int) {
            Log.d("tag_imageslide", "$position 째 bind")
            binding.setVariable(BR.item, item)
            binding.ivImage.setImageBitmap(stringToBitmap(item.body.toString()))
            binding.executePendingBindings()
        }
    }
}