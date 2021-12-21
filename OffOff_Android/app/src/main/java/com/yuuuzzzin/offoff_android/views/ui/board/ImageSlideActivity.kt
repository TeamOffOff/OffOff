package com.yuuuzzzin.offoff_android.views.ui.board

import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import android.view.View
import android.view.WindowInsets
import android.view.WindowManager
import androidx.activity.viewModels
import androidx.appcompat.widget.Toolbar
import androidx.viewpager2.widget.ViewPager2
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityImageSlideBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostImagesViewModel
import com.yuuuzzzin.offoff_android.views.adapter.ImageSlideAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ImageSlideActivity : BaseActivity<ActivityImageSlideBinding>(R.layout.activity_image_slide) {

    private val viewModel: PostImagesViewModel by viewModels()

    lateinit var postId: String
    lateinit var boardType: String
    private var startPosition: Int? = 0
    private lateinit var imageSlideAdapter: ImageSlideAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        processIntent()
        initView()
        initToolbar()
        initViewModel()
        initViewPager()

    }

    private fun processIntent() {
        postId = intent.getStringExtra("postId").toString()
        boardType = intent.getStringExtra("boardType").toString()
        startPosition = intent.getIntExtra("position", 0)
    }

    private fun initView() {

        // 풀스크린 모드
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.hide(WindowInsets.Type.statusBars())
        } else {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN
            )
        }
    }

    private fun initToolbar() {
        val toolbar: Toolbar = binding.toolbar
        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white_resized)
        }
    }

    private fun initViewModel() {

        viewModel.getPostImages(postId, boardType)

        // 로딩 화면 가시화 여부
        viewModel.loading.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    binding.layoutProgress.root.visibility = View.VISIBLE
                } else {
                    binding.layoutProgress.root.visibility = View.GONE
                }
            }
        })

        viewModel.imageList.observe(binding.lifecycleOwner!!, {
            if (!it.isNullOrEmpty()) {
                imageSlideAdapter.addPostImageList(it.toMutableList())

                // 뷰페이저 시작 위치 지정
                binding.viewPager.post {
                    binding.viewPager.currentItem = startPosition!!
                }

            }
        })
    }

    private fun initViewPager() {

        imageSlideAdapter = ImageSlideAdapter()

        Log.d("tag_position", startPosition.toString())
        binding.viewPager.apply {
            adapter = imageSlideAdapter
            orientation = ViewPager2.ORIENTATION_HORIZONTAL
        }

        binding.viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)
                Log.d("log_page", "페이지 넘김")
            }
        })
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