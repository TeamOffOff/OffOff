package com.yuuuzzzin.offoff_android.view.ui.board

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.DividerItemDecoration.VERTICAL
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityBoardBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.view.adapter.BoardAdapter
import com.yuuuzzzin.offoff_android.viewmodel.BoardViewModel
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable

@AndroidEntryPoint
class BoardActivity : BaseActivity<ActivityBoardBinding>(R.layout.activity_board) {

    private val viewModel: BoardViewModel by viewModels()
    private lateinit var boardAdapter: BoardAdapter
    private lateinit var boardName: String
    private lateinit var searchIcon: FontDrawable
    private lateinit var writeIcon: FontDrawable

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        processIntent()
        initViewModel()
        initToolbar()
        initRV()
    }

    private fun initViewModel() {
        binding.viewModel = viewModel
        viewModel.getPosts(intent.getStringExtra("boardType").toString())
        viewModel.postList.observe(binding.lifecycleOwner!!, {
            with(boardAdapter) { submitList(it.toMutableList()) }
        })
    }

    private fun processIntent() {
        boardName = intent.getStringExtra("boardName").toString()
    }

    private fun initToolbar() {
        val toolbar: MaterialToolbar = binding.appbarBoard // 상단 툴바
        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = boardName
            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_baseline_arrow_back_24)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun initRV() {
        val boardRecyclerView: RecyclerView = binding.rvPostPreview
        val linearLayoutManager = LinearLayoutManager(this)
        val decoration = DividerItemDecoration(this, VERTICAL)

        boardAdapter = BoardAdapter(
            itemClick = { item ->
                val intent = Intent(this@BoardActivity, PostActivity::class.java)
                intent.putExtra("id", item.id)
                intent.putExtra("boardName", boardName)
                intent.putExtra("boardType", item.boardType)
                startActivity(intent)
            }
        )

        boardRecyclerView.apply {
            adapter = boardAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(decoration)
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_board, menu)
        searchIcon = FontDrawable(this, R.string.fa_search_solid, true, false)
        searchIcon.setTextColor(ContextCompat.getColor(this, R.color.white))
        writeIcon = FontDrawable(this, R.string.fa_pen_solid, true, false)
        writeIcon.setTextColor(ContextCompat.getColor(this, R.color.white))
        menu!!.getItem(0).icon = searchIcon
        menu.getItem(1).icon = writeIcon
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_search -> {
                //검색 버튼 누를 시
                true
            }
            R.id.action_write -> {
                //글쓰기 버튼 누를 시
                val boardType = intent.getStringExtra("boardType")
                val intent = Intent(applicationContext, PostWriteActivity::class.java)
                intent.putExtra("boardType", boardType)
                startActivity(intent)
                true
            }
            android.R.id.home -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}