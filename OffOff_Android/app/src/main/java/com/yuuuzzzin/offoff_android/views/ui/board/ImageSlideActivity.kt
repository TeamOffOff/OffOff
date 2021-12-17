package com.yuuuzzzin.offoff_android.views.ui.board

import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import androidx.appcompat.widget.Toolbar
import androidx.viewpager2.widget.ViewPager2
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityImageSlideBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.views.adapter.ImageSlideAdapter

class ImageSlideActivity : BaseActivity<ActivityImageSlideBinding>(R.layout.activity_image_slide) {

    private lateinit var imageSlideAdapter: ImageSlideAdapter
    private var startPosition: Int? = 0
    //private var imageList: List<Image>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initToolbar()

        startPosition = intent.getIntExtra("position", 0)

        //imageList = intent.getSerializableExtra("imageList") as List<Image>

        imageSlideAdapter = ImageSlideAdapter(OffoffApplication.imageList)
        Log.d("tag_list", OffoffApplication.imageList.toString())
        binding.viewPager.apply {
            offscreenPageLimit = 1
            adapter = imageSlideAdapter
            orientation = ViewPager2.ORIENTATION_HORIZONTAL
            currentItem = startPosition!!
            adapter?.notifyDataSetChanged()
        }

        binding.viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)

                Log.d("log_page", "페이지 넘김")
            }
        })
    }

    private fun initToolbar() {
        val toolbar: Toolbar = binding.toolbar

        Log.d("tag_toolbar", "툴ㄹ바")


        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white_resized)
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}