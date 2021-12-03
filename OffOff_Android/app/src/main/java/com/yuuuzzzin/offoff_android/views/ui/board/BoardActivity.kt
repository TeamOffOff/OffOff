package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityBoardBinding
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.Constants
import com.yuuuzzzin.offoff_android.utils.Constants.toast
import com.yuuuzzzin.offoff_android.utils.NetworkManager
import com.yuuuzzzin.offoff_android.utils.PostWriteType
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.utils.base.BaseBaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.BoardViewModel
import com.yuuuzzzin.offoff_android.views.adapter.BoardAdapter
import dagger.hilt.android.AndroidEntryPoint
import java.io.Serializable
import java.lang.Boolean.FALSE
import java.lang.Boolean.TRUE

@AndroidEntryPoint
class BoardActivity : BaseBaseActivity<ActivityBoardBinding>(R.layout.activity_board) {

    private val viewModel: BoardViewModel by viewModels()
    private lateinit var boardAdapter: BoardAdapter
    private lateinit var boardName: String
    private lateinit var boardType: String
    private lateinit var currentPostList: Array<Post>
    private lateinit var lastPostId: String
    private var clickedPosition: Int? = 0
    private var isFirst: Boolean = TRUE
    //private var totalScrolled: Int = 0
    //private val density = resources.displayMetrics.density

    // 게시물 액티비티 요청 및 결과 처리
    private val requestPost = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        val resultCode = activityResult.resultCode // 결과 코드
        val data = activityResult.data // 인텐트 데이터

        if (resultCode == Activity.RESULT_OK) {
            Log.d("tag_post_item_update", "post 변경사항 발생으로 postList item 업데이트 필요")
            boardAdapter.updateItem(
                data!!.getSerializableExtra("post") as Post,
                clickedPosition!!
            )
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        processIntent()
        initView()
        initViewModel()
        initToolbar()
        initRV()
    }

    override fun init() {
        Log.d("tag_init", "이닛")
        val networkManager: NetworkManager? = this?.let { NetworkManager(it) }
        if (!networkManager?.checkNetworkState()!!) {
            this.toast(Constants.NETWORK_DISCONNECT)
            finish()
        }
    }


    private fun processIntent() {
        boardName = intent.getStringExtra("boardName").toString()
        boardType = intent.getStringExtra("boardType").toString()
    }

    private fun initView() {

//        binding.btClose.setOnClickListener {
//            binding.layoutSearch.visibility = View.GONE
//            binding.etSearch.text = null
//            binding.layoutCollapsing.minimumHeight = convertDPtoPX(this, 152)
//            isFirst = TRUE
//            isSearching = FALSE
//            viewModel.getPosts(boardType)
//        }

        binding.btWritePost.setOnClickListener {
            val intent = Intent(applicationContext, PostWriteActivity::class.java)
            intent.putExtra("boardType", boardType)
            intent.putExtra("postWriteType", PostWriteType.WRITE)
            startActivity(intent)
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel
        viewModel.getPosts(boardType, false)

        viewModel.loading.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    binding.layoutProgress.root.visibility = View.VISIBLE
                } else {
                    binding.layoutProgress.root.visibility = View.GONE
                }
            }
        })

        viewModel.postList.observe(binding.lifecycleOwner!!, {
            if (it == null) {
                boardAdapter.clearPostList()
            }
            boardAdapter.addPostList(it, isFirst)
            binding.refreshLayout.isRefreshing = false
            isFirst = FALSE
            currentPostList = it.toTypedArray()
        })

        viewModel.clearPostList.observe(binding.lifecycleOwner!!, {
            boardAdapter.clearPostList()
        })

        viewModel.lastPostId.observe(binding.lifecycleOwner!!, {
            lastPostId = it
        })

        viewModel.newPostList.observe(binding.lifecycleOwner!!, {
            boardAdapter.addPostList(it, isFirst)
            binding.refreshLayout.isRefreshing = false
            currentPostList = it.toTypedArray()
        })

//        binding.etSearch.setOnEditorActionListener { v, actionId, event ->
//            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
//                isFirst = TRUE
//                isSearching = TRUE
//
//                // 검색 첫 페이지이면
//                if (isFirst) {
//                    viewModel.searchPost(boardType, binding.etSearch.text.toString(), null)
//                } else { // 다음 페이지이면
//                    viewModel.searchPost(boardType, binding.etSearch.text.toString(), lastPostId)
//                }
//                return@setOnEditorActionListener true
//            }
//            return@setOnEditorActionListener false
//        }
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

    private fun initRV() {
        boardAdapter = BoardAdapter()

        val spaceDecoration = RecyclerViewUtils.VerticalSpaceItemDecoration(7) // 아이템 사이의 거리
        binding.rvPostPreview.apply {
            adapter = boardAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecoration)
            hasFixedSize()
        }

        boardAdapter.setOnPostClickListener(object :
            BoardAdapter.OnPostClickListener {
            override fun onClickPost(item: Post, position: Int) {
                clickedPosition = position
                val intent = Intent(this@BoardActivity, PostActivity::class.java).apply {
                    putExtra("id", item.id)
                    putExtra("position", position)
                    putExtra("boardType", item.boardType)
                    putExtra("postList", currentPostList as Serializable)
                }

                requestPost.launch(intent)
            }
        })

        binding.refreshLayout.setOnRefreshListener {
            isFirst = TRUE
            viewModel.getPosts(boardType, true)
        }

        binding.rvPostPreview.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)

                val lastPosition =
                    (recyclerView.layoutManager as LinearLayoutManager?)!!.findLastCompletelyVisibleItemPosition()
                val totalCount = recyclerView.adapter!!.itemCount - 1

                // 스크롤이 끝에 도달하면
                if (!binding.rvPostPreview.canScrollVertically(1) && lastPosition == totalCount) {
                    viewModel.getNextPosts(boardType, lastPostId)
                }

            }
        })
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_board, menu)

        val icon = getDrawable(R.drawable.bt_search_resize)
        menu!!.getItem(0).icon = icon

        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_search -> {
                // 검색 버튼 누를 시
                //binding.layoutSearch.visibility = View.VISIBLE // 가시화
                //binding.layoutCollapsing.minimumHeight = convertDPtoPX(this, 230) // 최소 높이 조정
                val intent = Intent(this, SearchPostActivity::class.java)
                intent.putExtra("boardType", boardType)
                intent.putExtra("boardName", boardName)
                startActivity(intent)
                true
            }
//            R.id.action_more_option -> {
//                // 더보기 옵션 누를 시
//
//                true
//            }
            android.R.id.home -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}