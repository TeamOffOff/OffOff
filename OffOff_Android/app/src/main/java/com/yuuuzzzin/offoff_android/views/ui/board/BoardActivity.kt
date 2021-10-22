package com.yuuuzzzin.offoff_android.views.ui.board

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.activity.viewModels
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.DividerItemDecoration.VERTICAL
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityBoardBinding
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.PostWriteType
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.BoardViewModel
import com.yuuuzzzin.offoff_android.views.adapter.BoardAdapter
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable
import java.io.Serializable

@AndroidEntryPoint
class BoardActivity : BaseActivity<ActivityBoardBinding>(R.layout.activity_board) {

    private val viewModel: BoardViewModel by viewModels()
    private lateinit var boardAdapter: BoardAdapter
    private lateinit var boardName: String
    private lateinit var boardType: String
    private lateinit var searchIcon: FontDrawable
    private lateinit var writeIcon: FontDrawable
    private lateinit var currentPostList: Array<Post>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        processIntent()
        initViewModel()
        initToolbar()
        initRV()
    }

    private fun processIntent() {
        boardName = intent.getStringExtra("boardName").toString()
        boardType = intent.getStringExtra("boardType").toString()
    }

    private fun initViewModel() {
        binding.viewModel = viewModel
        viewModel.getPosts(boardType)

        viewModel.postList.observe(binding.lifecycleOwner!!, {
            boardAdapter.submitList(it.toMutableList()) {
                binding.rvPostPreview.scrollToPosition(0)
            }
            binding.refreshLayout.isRefreshing = false
            currentPostList = it.toTypedArray()
        })

        viewModel.newPostList.observe(binding.lifecycleOwner!!, {
            boardAdapter.submitList(it.toMutableList())
            binding.refreshLayout.isRefreshing = false
            currentPostList = it.toTypedArray()
        })

    }

    private fun initToolbar() {
        setSupportActionBar(binding.appbarBoard)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = boardName
            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_baseline_arrow_back_24)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun initRV() {
        boardAdapter = BoardAdapter()
//            itemClick = { item ->
//                val intent = Intent(this@BoardActivity, PostActivity::class.java)
//                intent.putExtra("id", item.id)
//                intent.putExtra("position", )
//                intent.putExtra("boardName", boardName)
//                intent.putExtra("boardType", item.boardType)
//                startActivity(intent)
//            }

        binding.rvPostPreview.apply {
            adapter = boardAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(DividerItemDecoration(context, VERTICAL))
        }

        boardAdapter.setOnClickPostListener(object :
            BoardAdapter.OnClickPostListener {
            override fun onClickPost(position: Int, item: Post) {
                val intent = Intent(this@BoardActivity, PostActivity::class.java)
                intent.putExtra("id", item.id)
                intent.putExtra("position", position)
                intent.putExtra("boardName", boardName)
                intent.putExtra("boardType", item.boardType)
                intent.putExtra("postList", currentPostList as Serializable)
                startActivityForResult(intent, 1)
            }
        })

        binding.refreshLayout.setOnRefreshListener {
            viewModel.getPosts(boardType)
        }

        binding.rvPostPreview.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)

                val lastPosition = (recyclerView.layoutManager as LinearLayoutManager?)!!.findLastCompletelyVisibleItemPosition()
                val totalCount = recyclerView.adapter!!.itemCount - 1

                // 스크롤이 끝에 도달하면
                if (!binding.rvPostPreview.canScrollVertically(1) && lastPosition == totalCount) {
                    Toast.makeText(this@BoardActivity, "스크롤이 최하단에 도달", Toast.LENGTH_SHORT).show()
                    viewModel.getPosts(boardType)
                }
            }
        })
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
                val intent = Intent(applicationContext, PostWriteActivity::class.java)
                intent.putExtra("boardType", boardType)
                intent.putExtra("boardName", boardName)
                intent.putExtra("postWriteType", PostWriteType.WRITE)
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if(requestCode == 1) {
            Log.d("tag_like", "requestCode")
            if(resultCode == RESULT_OK) {
                Log.d("tag_like", "저아요하고 뒤로가기함")
                viewModel.updatePost(data!!.getSerializableExtra("postList") as Array<Post>)
            }
        }
    }
}