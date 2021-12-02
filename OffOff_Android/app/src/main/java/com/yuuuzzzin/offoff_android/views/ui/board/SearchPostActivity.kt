package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.MenuItem
import android.view.inputmethod.EditorInfo
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivitySearchPostBinding
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.SearchPostViewModel
import com.yuuuzzzin.offoff_android.views.adapter.BoardAdapter
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.*
import java.io.Serializable

@AndroidEntryPoint
class SearchPostActivity : BaseActivity<ActivitySearchPostBinding>(R.layout.activity_search_post) {

    private val viewModel: SearchPostViewModel by viewModels()
    private lateinit var postListAdapter: BoardAdapter
    private lateinit var boardName: String
    private lateinit var boardType: String
    private lateinit var lastPostId: String
    private lateinit var currentPostList: Array<Post>
    private var clickedPosition: Int? = 0
    private var searchingQuery: String? = null
    private var isFirst: Boolean = true

    // 게시물 액티비티 요청 및 결과 처리
    private val requestPost = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        val resultCode = activityResult.resultCode // 결과 코드
        val data = activityResult.data // 인텐트 데이터

        if (resultCode == Activity.RESULT_OK) {
            Log.d("tag_post_item_update", "post 변경사항 발생으로 postList item 업데이트 필요")
            postListAdapter.updateItem(
                data!!.getSerializableExtra("post") as Post,
                clickedPosition!!
            )
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        processIntent()
        initToolbar()
        initViewModel()
        initView()
        initRV()
    }

    private fun processIntent() {
        boardName = intent.getStringExtra("boardName").toString()
        boardType = intent.getStringExtra("boardType").toString()
    }

    private fun initToolbar() {
        setSupportActionBar(binding.toolbar)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = boardName
            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white_resized)
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        viewModel.postList.observe(binding.lifecycleOwner!!, {
            postListAdapter.addPostList(it, isFirst)
            binding.refreshLayout.isRefreshing = false
            currentPostList = it.toTypedArray()
        })

        viewModel.lastPostId.observe(binding.lifecycleOwner!!, {
            lastPostId = it
        })
    }

    private fun initView() {

        binding.etSearch.requestFocus()
        binding.etSearch.addTextChangedListener(object : TextWatcher {

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val query = s.toString()

                if (query == searchingQuery)
                    return

                searchingQuery = query

                val coroutineScope = CoroutineScope(Job() + Dispatchers.Main)
                coroutineScope.launch {
                    delay(500)  // debounce timeOut
                    if (query != searchingQuery)
                        return@launch

                    if (searchingQuery.isNullOrBlank()) {
                        postListAdapter.clearPostList()
                    } else {
                        Log.d("tag_textWatcher 감지!!!", query)
                        isFirst = true
                        viewModel.searchPost(boardType, query, null)
                    }
                }
            }

            override fun afterTextChanged(s: Editable?) {
            }

        })

        binding.etSearch.setOnEditorActionListener { v, actionId, event ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                if (!binding.etSearch.text.isNullOrBlank()) {
                    isFirst = true
                    viewModel.totalSearchPost(binding.etSearch.text.toString(), null)
                }

                return@setOnEditorActionListener true
            }
            return@setOnEditorActionListener false
        }

        binding.refreshLayout.setOnRefreshListener {
            isFirst = true
            if (!searchingQuery.isNullOrBlank()) {
                viewModel.searchPost(
                    boardType,
                    searchingQuery.toString(),
                    null
                )
            }
        }
    }

    private fun initRV() {
        postListAdapter = BoardAdapter()

        val spaceDecoration = RecyclerViewUtils.VerticalSpaceItemDecoration(7) // 아이템 사이의 거리
        binding.rvPostPreview.apply {
            adapter = postListAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecoration)
        }

        postListAdapter.setOnPostClickListener(object :
            BoardAdapter.OnPostClickListener {
            override fun onClickPost(item: Post, position: Int) {
                clickedPosition = position
                val intent = Intent(this@SearchPostActivity, PostActivity::class.java).apply {
                    putExtra("id", item.id)
                    putExtra("position", position)
                    putExtra("boardType", item.boardType)
                    putExtra("postList", currentPostList as Serializable)
                }

                requestPost.launch(intent)
            }
        })

        binding.rvPostPreview.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)

                val lastPosition =
                    (recyclerView.layoutManager as LinearLayoutManager?)!!.findLastCompletelyVisibleItemPosition()
                val totalCount = recyclerView.adapter!!.itemCount - 1

                // 스크롤이 끝에 도달하면
                if (!binding.rvPostPreview.canScrollVertically(1) && lastPosition == totalCount) {

                    if (!searchingQuery.isNullOrBlank()) {
                        isFirst = false
                        viewModel.searchPost(
                            boardType,
                            searchingQuery.toString(),
                            lastPostId
                        )
                    }
                }
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