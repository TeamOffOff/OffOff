package com.yuuuzzzin.offoff_android.views.ui.board

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.recyclerview.widget.GridLayoutManager
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.databinding.FragmentBoardsBinding
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.viewmodel.BoardListViewModel
import com.yuuuzzzin.offoff_android.views.adapter.BoardListAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class BoardsFragment : Fragment() {

    // ViewBinding
    private var mBinding: FragmentBoardsBinding? = null
    private val binding get() = mBinding!!
    private val viewModel: BoardListViewModel by viewModels()
    private lateinit var mContext: Context
    private lateinit var boardListAdapter: BoardListAdapter

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is MainActivity) {
            this.mContext = context
        } else {
            throw RuntimeException("$context error")
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        mBinding = FragmentBoardsBinding.inflate(inflater, container, false)

        initView()
        initViewModel()
        initRV()

        return binding.root
    }

    private fun initView() {
        binding.tvNickname.text = "${OffoffApplication.user.subInfo.nickname} 님"
    }

    private fun initViewModel() {
        binding.viewModel = viewModel
        viewModel.boardList.observe(viewLifecycleOwner, {
            with(boardListAdapter) { addBoardList(it.toMutableList()) }
        })
    }

    private fun initRV() {
        boardListAdapter = BoardListAdapter()

        boardListAdapter.setOnBoardClickListener(object :
            BoardListAdapter.OnBoardClickListener {

            override fun onClickBoard(item: Board, position: Int) {
                val intent = Intent(mContext, BoardActivity::class.java)
                intent.putExtra("boardType", item.boardType)
                intent.putExtra("boardName", item.name)
                startActivity(intent)
            }
        })

        val spaceDecoration = RecyclerViewUtils.VerticalSpaceItemDecoration(16) // 아이템 사이의 거리
        binding.rvBoards.apply {
            layoutManager = GridLayoutManager(mContext, 3)
            addItemDecoration(spaceDecoration)
            adapter = boardListAdapter
        }

        binding.rvBoardsFavorite.apply {
            layoutManager = GridLayoutManager(mContext, 3)
            addItemDecoration(spaceDecoration)
            adapter = boardListAdapter
        }
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}