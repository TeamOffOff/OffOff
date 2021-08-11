package com.yuuuzzzin.offoff_android.view.ui.board

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.DividerItemDecoration.VERTICAL
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.databinding.FragmentBoardsBinding
import com.yuuuzzzin.offoff_android.view.adapter.BoardListAdapter
import com.yuuuzzzin.offoff_android.viewmodel.BoardListViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class BoardsFragment : Fragment() {

    // ViewBinding
    private var mBinding: FragmentBoardsBinding? = null
    private val binding get() = mBinding!!
    private val viewModel: BoardListViewModel by viewModels()
    lateinit var mContext: Context

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

        initViewModel()
        initRV()

        return binding.root
    }

    private fun initViewModel() {
        binding.viewModel = viewModel
        viewModel.boardList.observe(viewLifecycleOwner, {
            with(boardListAdapter) { submitList(it.toMutableList()) }
        })
    }

    private fun initRV() {
        val boardListRecyclerView: RecyclerView = binding.rvBoards
        val linearLayoutManager = LinearLayoutManager(mContext)
        val decoration = DividerItemDecoration(mContext, VERTICAL)

        boardListAdapter = BoardListAdapter(
            itemClick = { item ->
                val intent = Intent(mContext, BoardActivity::class.java)
                intent.putExtra("boardType", item.boardType)
                intent.putExtra("boardName", item.name)
                startActivity(intent)
            }
        )

        boardListRecyclerView.apply {
            adapter = boardListAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(decoration)
        }
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}