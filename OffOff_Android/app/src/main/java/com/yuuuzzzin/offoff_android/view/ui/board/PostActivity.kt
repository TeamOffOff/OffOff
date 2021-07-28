package com.yuuuzzzin.offoff_android.view.ui.board

import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.databinding.ActivityPostBinding
import com.yuuuzzzin.offoff_android.viewmodel.PostViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class PostActivity : AppCompatActivity() {

    private var mBinding: ActivityPostBinding? = null
    private val binding get() = mBinding!!
    private val viewModel: PostViewModel by viewModels()

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

    }

    private fun initPost() {

        viewModel.responsePost.observe(this, { post ->
            binding.apply {
                tvAuthor.text = post.author
                tvDate.text = post.date
                tvTitle.text = post.title
                tvContent.text = post.content
            }
        })
    }

    private fun initToolbar() {
        val toolbar : MaterialToolbar = binding.appbarPost

        setSupportActionBar(toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        supportActionBar?.apply {
            toolbar.title = intent.getStringExtra("appBarTitle")

            setDisplayHomeAsUpEnabled(true)
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