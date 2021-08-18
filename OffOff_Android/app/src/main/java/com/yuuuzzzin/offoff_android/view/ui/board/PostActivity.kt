package com.yuuuzzzin.offoff_android.view.ui.board

import android.content.Intent
import android.os.Bundle
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.core.content.ContextCompat
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostViewModel
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable

@AndroidEntryPoint
class PostActivity : BaseActivity<ActivityPostBinding>(R.layout.activity_post) {

    private val viewModel: PostViewModel by viewModels()
    private lateinit var boardName: String
    private lateinit var boardType: String
    private lateinit var writeIcon: FontDrawable
    private lateinit var likeIcon: FontDrawable

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initViewModel()
        processIntent()
        initToolbar()
        initView()
    }

    private fun processIntent() {
        val id = intent.getStringExtra("id")
        boardType = intent.getStringExtra("boardType").toString()
        boardName = intent.getStringExtra("boardName").toString()
        viewModel.getPost(id!!, boardType!!)
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        viewModel.response.observe(binding.lifecycleOwner!!, {
            binding.post = it
        })
    }

    private fun initToolbar() {
        val toolbar: MaterialToolbar = binding.appbar

        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = boardName

            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_baseline_arrow_back_24)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun initView() {
        writeIcon = FontDrawable(this, R.string.fa_pen_solid, true, false)
        writeIcon.setTextColor(ContextCompat.getColor(this, R.color.green))

        likeIcon = FontDrawable(this, R.string.fa_thumbs_up_solid, true, false)
        likeIcon.setTextColor(ContextCompat.getColor(this, R.color.red))

        binding.tfId.endIconDrawable = writeIcon
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                if (intent.getStringExtra("update") == "true") {
                    val intent = Intent(applicationContext, BoardActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                    intent.putExtra("boardType", boardType)
                    intent.putExtra("boardName", boardName)
                    startActivity(intent)
                    finish()
                } else
                    finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}