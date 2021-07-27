package com.yuuuzzzin.offoff_android.view.ui.board

import android.content.Intent
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentBoardsBinding
import com.yuuuzzzin.offoff_android.service.models.Board
import com.yuuuzzzin.offoff_android.view.adapter.BoardListAdapter

class BoardsFragment : Fragment() {

    // ViewBinding
    private var mBinding: FragmentBoardsBinding? = null
    private val binding get() = mBinding!!

    private lateinit var boardListAdapter: BoardListAdapter

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = FragmentBoardsBinding.inflate(inflater, container, false)

        val decoration = DividerItemDecoration(context, DividerItemDecoration.VERTICAL)

        boardListAdapter = BoardListAdapter()

        binding.rvBoards.adapter = boardListAdapter

        binding.rvBoards.addItemDecoration(decoration)

        binding.rvBoards.layoutManager =
            LinearLayoutManager(context).also { it.orientation = LinearLayoutManager.VERTICAL }

        boardListAdapter.boardList.addAll(
            listOf(
                Board("자유 게시판", R.drawable.ic_twotone_list_alt_24),
                Board("익명 게시판", R.drawable.ic_twotone_textsms_24),
                Board("HOT 게시판", R.drawable.ic_twotone_local_fire_department_24),
                Board("BEST 게시판", R.drawable.ic_twotone_thumb_up_24),
                Board("스크랩", R.drawable.ic_twotone_star_24),
                Board("좋아요", R.drawable.ic_twotone_favorite_24)
            ),
        )

        /*board click listener 재정의*/
        boardListAdapter.setOnBoardClickListener(object :
            BoardListAdapter.OnBoardClickListener{
            override fun onBoardClick(view: View, board: Board) {
                val intent = Intent(activity, BoardActivity::class.java)
                intent.putExtra("title", board.title)
                startActivity(intent)
            }
        })

        return binding.root
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}