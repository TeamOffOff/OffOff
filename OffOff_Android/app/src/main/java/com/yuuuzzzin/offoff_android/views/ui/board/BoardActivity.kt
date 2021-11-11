package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityBoardBinding
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.Constants.convertDPtoPX
import com.yuuuzzzin.offoff_android.utils.PostWriteType
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.BoardViewModel
import com.yuuuzzzin.offoff_android.views.adapter.BoardAdapter
import dagger.hilt.android.AndroidEntryPoint
import java.io.Serializable
import java.lang.Boolean.FALSE
import java.lang.Boolean.TRUE

@AndroidEntryPoint
class BoardActivity : BaseActivity<ActivityBoardBinding>(R.layout.activity_board) {

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

    private fun processIntent() {
        boardName = intent.getStringExtra("boardName").toString()
        boardType = intent.getStringExtra("boardType").toString()
    }

    private fun initView() {
        binding.btClose.setOnClickListener {
            binding.layoutSearch.visibility = View.GONE
            binding.layoutCollapsing.minimumHeight = convertDPtoPX(this, 152)
        }

        binding.btWritePost.setOnClickListener {
            val intent = Intent(applicationContext, PostWriteActivity::class.java)
            intent.putExtra("boardType", boardType)
            intent.putExtra("boardName", boardName)
            intent.putExtra("postWriteType", PostWriteType.WRITE)
            startActivity(intent)
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel
        viewModel.getPosts(boardType)

        viewModel.postList.observe(binding.lifecycleOwner!!, {
            boardAdapter.addPostList(it, isFirst)
            binding.refreshLayout.isRefreshing = false
            isFirst = FALSE
            currentPostList = it.toTypedArray()
        })

        viewModel.lastPostId.observe(binding.lifecycleOwner!!, {
            lastPostId = it
        })

        viewModel.newPostList.observe(binding.lifecycleOwner!!, {
            boardAdapter.addPostList(it, isFirst)
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
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun initRV() {
        boardAdapter = BoardAdapter()

        val spaceDecoration = RecyclerViewUtils.VerticalSpaceItemDecoration(7) // 아이템 사이의 거리
        binding.rvPostPreview.apply {
            adapter = boardAdapter
            boardAdapter.stateRestorationPolicy =
                RecyclerView.Adapter.StateRestorationPolicy.PREVENT_WHEN_EMPTY // 리사이클러뷰의 스크롤된 position 유지
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecoration)
        }

        boardAdapter.setOnPostClickListener(object :
            BoardAdapter.OnPostClickListener {
            override fun onClickPost(item: Post, position: Int) {
                clickedPosition = position
                val intent = Intent(this@BoardActivity, PostActivity::class.java).apply {
                    putExtra("id", item.id)
                    putExtra("position", position)
                    putExtra("boardName", boardName)
                    putExtra("boardType", item.boardType)
                    putExtra("postList", currentPostList as Serializable)
                }

                requestPost.launch(intent)
            }
        })

        binding.refreshLayout.setOnRefreshListener {
            isFirst = TRUE
            viewModel.getPosts(boardType)
        }

        binding.rvPostPreview.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)

                val lastPosition =
                    (recyclerView.layoutManager as LinearLayoutManager?)!!.findLastCompletelyVisibleItemPosition()
                val totalCount = recyclerView.adapter!!.itemCount - 1

                // 스크롤이 끝에 도달하면
                if (!binding.rvPostPreview.canScrollVertically(1) && lastPosition == totalCount) {
                    Toast.makeText(this@BoardActivity, "스크롤이 최하단에 도달", Toast.LENGTH_SHORT).show()
                    viewModel.getNextPosts(boardType, lastPostId)
                }
            }
        })
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_board, menu)
        //menu!!.getItem(0).icon = getDrawable(R.drawable.ic_search)
        //menu.getItem(1).icon = getDrawable(R.drawable.ic_more_option)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_search -> {
                // 검색 버튼 누를 시
                binding.layoutSearch.visibility = View.VISIBLE // 가시화
                binding.layoutCollapsing.minimumHeight = convertDPtoPX(this, 230) // 최소 높이 조정
                true
            }
            R.id.action_more_option -> {
                // 더보기 옵션 누를 시

                true
            }
            android.R.id.home -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//        if (requestCode == 1) {
//            Log.d("tag_like", "requestCode")
//            if (resultCode == RESULT_OK) {
//                Log.d("tag_like", "저아요하고 뒤로가기함")
//                boardAdapter.updateItem(
//                    data!!.getSerializableExtra("post") as Post,
//                    clickedPosition!!
//                )
//
//            }
//        }
//    }
}