package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.View
import android.view.inputmethod.EditorInfo
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.viewModels
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentBoardsBinding
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.Constants.makeDefaultSnackbar
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.utils.base.BaseFragment
import com.yuuuzzzin.offoff_android.viewmodel.BoardListViewModel
import com.yuuuzzzin.offoff_android.views.adapter.BoardAdapter
import com.yuuuzzzin.offoff_android.views.adapter.BoardListAdapter
import com.yuuuzzzin.offoff_android.views.ui.user.UserPostActivity
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.*
import java.io.Serializable

@AndroidEntryPoint
class BoardsFragment : BaseFragment<FragmentBoardsBinding>(R.layout.fragment_boards) {

    private val viewModel: BoardListViewModel by viewModels()
    private lateinit var callback: OnBackPressedCallback
    private var backPressedTime: Long = 0

    private lateinit var boardListAdapter: BoardListAdapter
    private lateinit var postListAdapter: BoardAdapter
    private lateinit var lastPostId: String
    private var currentPostList: Array<Post> = emptyArray()
    private var clickedPosition: Int? = 0
    private var searchingQuery: String? = null
    private var isFirst: Boolean = true

    // ????????? ???????????? ?????? ??? ?????? ??????
    private val requestPost = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        val resultCode = activityResult.resultCode // ?????? ??????
        val data = activityResult.data // ????????? ?????????

        if (resultCode == Activity.RESULT_OK) {
            Log.d("tag_post_item_update", "post ???????????? ???????????? postList item ???????????? ??????")
            postListAdapter.updateItem(
                data!!.getSerializableExtra("post") as Post,
                clickedPosition!!
            )
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        callback = object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {

                // ??? ?????? 2??? ??? ?????? ?????? ??? ??? ??????
                if (System.currentTimeMillis() - backPressedTime < 2000) {
                    activity!!.finish()
                    return
                }

                // ??? ?????? ?????? ?????? ???
                makeDefaultSnackbar(view!!, "???????????? ????????? ??? ??? ??? ????????? ?????? ???????????????.")
//                requireContext().toast("???????????? ????????? ??? ??? ??? ?????????\n?????? ???????????????.")
                backPressedTime = System.currentTimeMillis()

            }
        }

        requireActivity().onBackPressedDispatcher.addCallback(this, callback)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initViewModel()
        initRV()
        initView()
    }

    private fun initView() {
        binding.tvNickname.text = "${OffoffApplication.user.subInfo.nickname} ???"

        binding.btScrap.setOnClickListener {
            val intent = Intent(mContext, UserPostActivity::class.java)
            intent.putExtra("option", "???????????? ???")
            startActivity(intent)
        }

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
                    delay(500) // debounce timeOut
                    if (query != searchingQuery)
                        return@launch

                    if (searchingQuery.isNullOrBlank()) {
                        postListAdapter.clearPostList()
                        binding.rvPostPreview.visibility = View.GONE
                        binding.layoutNoResult.visibility = View.GONE
                        binding.layoutBoards.visibility = View.VISIBLE
                    } else {
                        Log.d("tag_textWatcher ??????", query)
                        binding.layoutBoards.visibility = View.GONE
                        binding.layoutNoResult.visibility = View.GONE
                        binding.rvPostPreview.visibility = View.VISIBLE
                        isFirst = true
                        Log.d("tag_isFirst", "isFirst??????")
                        viewModel.totalSearchPost(query, null)
                    }
                }
            }

            override fun afterTextChanged(s: Editable?) {
            }

        })

        binding.etSearch.setOnEditorActionListener { v, actionId, event ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                if (!binding.etSearch.text.isNullOrBlank()) {
                    binding.layoutBoards.visibility = View.GONE
                    binding.rvPostPreview.visibility = View.VISIBLE
                    isFirst = true
                    viewModel.totalSearchPost(binding.etSearch.text.toString(), null)
                }

                return@setOnEditorActionListener true
            }
            return@setOnEditorActionListener false
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        viewModel.loading.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    binding.layoutProgress.root.visibility = View.VISIBLE
                } else {
                    binding.layoutProgress.root.visibility = View.GONE
                }
            }
        })

        viewModel.boardList.observe(viewLifecycleOwner, {
            with(boardListAdapter) { addBoardList(it.toMutableList()) }
        })

        viewModel.postList.observe(binding.lifecycleOwner!!, {
            // ?????? ????????? ?????? ???
            if (it.isNullOrEmpty()) {
                postListAdapter.addPostList(it, isFirst)
                if (isFirst || currentPostList.isEmpty()) {
                    postListAdapter.clearPostList()
                    binding.rvPostPreview.visibility = View.GONE
                    binding.layoutNoResult.visibility = View.VISIBLE
                    currentPostList = emptyArray()
                }
                Log.d("tag_nullOrEmpty", currentPostList.size.toString())
            }
            // ?????? ????????? ?????? ???
            else {
                if (isFirst) {
                    binding.rvPostPreview.visibility = View.VISIBLE
                    binding.layoutNoResult.visibility = View.GONE
                    currentPostList = it.toTypedArray()
                } else {
                    currentPostList += it.toTypedArray()
                }
                postListAdapter.addPostList(it, isFirst)
                Log.d("tag_!nullOrEmpty", currentPostList.size.toString())
            }
        })

        viewModel.lastPostId.observe(binding.lifecycleOwner!!, {
            lastPostId = it
        })
    }

    private fun initRV() {
        boardListAdapter = BoardListAdapter()

        binding.rvBoards.apply {
            layoutManager = GridLayoutManager(mContext, 3)
            adapter = boardListAdapter
            hasFixedSize()
        }

        boardListAdapter.setOnBoardClickListener(object :
            BoardListAdapter.OnBoardClickListener {

            override fun onClickBoard(item: Board, position: Int) {
                val intent = Intent(mContext, BoardActivity::class.java)
                intent.putExtra("boardType", item.boardType)
                intent.putExtra("boardName", item.name)
                startActivity(intent)
            }
        })

        binding.rvBoardsFavorite.apply {
            layoutManager = GridLayoutManager(mContext, 3)
            adapter = boardListAdapter
            hasFixedSize()
        }

        postListAdapter = BoardAdapter()

        val spaceDecoration = RecyclerViewUtils.VerticalSpaceItemDecoration(7) // ????????? ????????? ??????
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
                val intent = Intent(mContext, PostActivity::class.java).apply {
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

                // ???????????? ?????? ????????????
                if (!binding.rvPostPreview.canScrollVertically(1) && lastPosition == totalCount) {

                    if (!searchingQuery.isNullOrBlank()) {
                        isFirst = false
                        viewModel.totalSearchPost(
                            searchingQuery.toString(),
                            lastPostId
                        )
                    }
                }
            }
        })
    }
}