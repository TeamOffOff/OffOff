package com.yuuuzzzin.offoff_android.view.ui.board

import android.content.Intent
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.DividerItemDecoration.VERTICAL
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.databinding.*
import com.yuuuzzzin.offoff_android.service.models.PostPreview
import com.yuuuzzzin.offoff_android.view.adapter.BoardAdapter
import com.yuuuzzzin.offoff_android.viewmodel.BoardViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class BoardActivity : AppCompatActivity() {

    private var mBinding: ActivityBoardBinding? = null
    private val binding get() = mBinding!!
    private val viewModel: BoardViewModel by viewModels()
    private lateinit var boardAdapter: BoardAdapter

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        mBinding = ActivityBoardBinding.inflate(layoutInflater)
        setContentView(binding.root)

        initToolbar()
        setUpRv()
    }

    // 액티비티가 Destroy될 때
    override fun onDestroy() {
        // onDestroy 에서 binding class 인스턴스 참조를 정리해주어야 함
        mBinding = null
        super.onDestroy()
    }

    private fun initToolbar() {
        val toolbar : MaterialToolbar = binding.appbarBoard // 상단 툴바

        setSupportActionBar(toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성

        supportActionBar?.apply {
            toolbar.title = intent.getStringExtra("title")

            setDisplayHomeAsUpEnabled(true)
            setDisplayShowHomeEnabled(true)
        }

    }

    private fun setUpRv() {
        val decoration = DividerItemDecoration(this, VERTICAL)
        boardAdapter = BoardAdapter()

        binding.rvPostPreview.apply {
            adapter = boardAdapter
            addItemDecoration(decoration)
            layoutManager = LinearLayoutManager(
                this@BoardActivity, LinearLayoutManager.VERTICAL, false)
        }

        viewModel.responsePost.observe(this, {

            boardAdapter.posts = it.post_list
        })

        /* click listener 재정의 */
        boardAdapter.setOnItemClickListener(object : BoardAdapter.OnItemClickListener {
            override fun onItemClick(view: View, postPreview: PostPreview) {

                val id = postPreview.id

                val intent = Intent(this@BoardActivity, PostActivity::class.java)
                intent.putExtra("appBarTitle", binding.appbarBoard.title)
                intent.putExtra("id", id)
                startActivity(intent)
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