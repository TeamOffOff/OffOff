package com.yuuuzzzin.offoff_android.view.ui.board

import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostBinding
import com.yuuuzzzin.offoff_android.viewmodel.PostViewModel
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable

@AndroidEntryPoint
class PostActivity : AppCompatActivity() {

    private var mBinding: ActivityPostBinding? = null
    private val binding get() = mBinding!!
    private val viewModel: PostViewModel by viewModels()
    private lateinit var writeIcon: FontDrawable
    private lateinit var likeIcon: FontDrawable

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val id = intent.getStringExtra("id")
        val boardType = intent.getStringExtra("boardType")
        Log.e("tag_check","postID : $id")
        viewModel.getPost(id!!, boardType!!)

        mBinding = ActivityPostBinding.inflate(layoutInflater)
        setContentView(binding.root)

        initToolbar()
        initPost()
        initView()

    }

    private fun initPost() {

        viewModel.responsePost.observe(this, { post ->
            binding.apply {
                tvAuthor.text = post.author
                tvDate.text = post.date
                tvTitle.text = post.title
                tvContent.text = post.content
                tvLikes.text = post.likes.toString()
            }
        })
    }

    private fun initView() {
        writeIcon = FontDrawable(this, R.string.fa_pen_solid, true, false)
        writeIcon.setTextColor(ContextCompat.getColor(this, R.color.green))

        likeIcon = FontDrawable(this, R.string.fa_thumbs_up_solid, true, false)
        likeIcon.setTextColor(ContextCompat.getColor(this, R.color.red))

        binding.tfId.endIconDrawable = writeIcon
    }

    private fun initToolbar() {
        val toolbar : MaterialToolbar = binding.appbar

        setSupportActionBar(toolbar)
        Log.d("앱바타이틀_tag", intent.getStringExtra("appBarTitle").toString())
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = intent.getStringExtra("appBarTitle")

            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_baseline_arrow_back_24)
            setDisplayShowHomeEnabled(true)
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

    override fun onDestroy() {
        mBinding = null
        super.onDestroy()
    }
}