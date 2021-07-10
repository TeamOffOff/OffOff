package com.yuuuzzzin.offoff_android.view.ui

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.MenuItem
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.service.model.Metadata
import com.yuuuzzzin.offoff_android.databinding.ActivityPostBinding
import com.yuuuzzzin.offoff_android.service.model.Contents

class PostActivity : AppCompatActivity() {

    // ViewBinding
    private var mBinding: ActivityPostBinding? = null
    private val binding get() = mBinding!!

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_post)

        mBinding = ActivityPostBinding.inflate(layoutInflater)
        setContentView(binding.root)

        init()
        initToolbar()

    }

    private fun init() {

        val metadata = intent.getParcelableExtra("metadata") as? Metadata
        val contents = intent.getParcelableExtra("contents") as? Contents
        binding.tvAuthor.text = metadata!!.author
        binding.tvDate.text = metadata.date
        binding.tvTitle.text = metadata.title
        binding.tvContent.text = contents?.content

    }

    private fun initToolbar() {
        val toolbar : MaterialToolbar = binding.appbarPost // 상단 툴바

        setSupportActionBar(toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성

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

    // 액티비티가 Destroy될 때
    override fun onDestroy() {
        // onDestroy 에서 binding class 인스턴스 참조를 정리해주어야 함
        mBinding = null
        super.onDestroy()
    }
}