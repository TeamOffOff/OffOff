package com.yuuuzzzin.offoff_android.views.ui.user

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityUserPostBinding
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.utils.UserPostType.MY_BOOKMARK_POST
import com.yuuuzzzin.offoff_android.utils.UserPostType.MY_COMMENT_POST
import com.yuuuzzzin.offoff_android.utils.UserPostType.MY_POST
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.UserPostViewModel
import com.yuuuzzzin.offoff_android.views.adapter.BoardAdapter
import com.yuuuzzzin.offoff_android.views.ui.board.PostActivity
import dagger.hilt.android.AndroidEntryPoint
import java.io.Serializable

@AndroidEntryPoint
class UserPostActivity : BaseActivity<ActivityUserPostBinding>(R.layout.activity_user_post) {

    private val viewModel: UserPostViewModel by viewModels()
    private lateinit var postListAdapter: BoardAdapter
    private lateinit var currentPostList: Array<Post>
    private lateinit var option: String
    private var clickedPosition: Int? = 0

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
        initRV()
    }

    private fun processIntent() {
        option = intent.getStringExtra("option").toString()
    }

    private fun initToolbar() {
        setSupportActionBar(binding.toolbar)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = option
            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white_resized)
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        when (option) {
            MY_POST -> {
                viewModel.getMyPostList(false)
            }
            MY_COMMENT_POST -> {
                viewModel.getMyCommentPostList(false)
            }
            MY_BOOKMARK_POST -> {
                viewModel.getMyBookmarkPostList(false)
            }
        }

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
                postListAdapter.clearPostList()
            }
            postListAdapter.addPostList(it, true)
            binding.refreshLayout.isRefreshing = false
            currentPostList = it.toTypedArray()
        })
    }

    private fun initRV() {
        postListAdapter = BoardAdapter()

        val spaceDecoration = RecyclerViewUtils.VerticalSpaceItemDecoration(7) // 아이템 사이의 거리
        binding.rvPostPreview.apply {
            adapter = postListAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecoration)
            hasFixedSize()
        }

        postListAdapter.setOnPostClickListener(object :
            BoardAdapter.OnPostClickListener {
            override fun onClickPost(item: Post, position: Int) {
                clickedPosition = position
                val intent = Intent(this@UserPostActivity, PostActivity::class.java).apply {
                    putExtra("id", item.id)
                    putExtra("position", position)
                    putExtra("boardType", item.boardType)
                    putExtra("postList", currentPostList as Serializable)
                }

                requestPost.launch(intent)
            }
        })

        binding.refreshLayout.setOnRefreshListener {
            when (option) {
                MY_POST -> {
                    viewModel.getMyPostList(true)
                }
                MY_COMMENT_POST -> {
                    viewModel.getMyCommentPostList(true)
                }
                MY_BOOKMARK_POST -> {
                    viewModel.getMyBookmarkPostList(true)
                }
            }
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
//            R.id.action_search -> {
//                // 검색 버튼 누를 시
//                //binding.layoutSearch.visibility = View.VISIBLE // 가시화
//                //binding.layoutCollapsing.minimumHeight = convertDPtoPX(this, 230) // 최소 높이 조정
//                val intent = Intent(this, ::class.java)
//                intent.putExtra("boardType", boardType)
//                intent.putExtra("boardName", boardName)
//                startActivity(intent)
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