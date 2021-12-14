package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemBoardBinding
import com.yuuuzzzin.offoff_android.service.models.Board

/*
* BoardActivity의 게시물 목록을 보여주는
* RecyclerView를 위한 Adapter
*/

//
//class BoardListAdapter(
//    itemClick: (Board) -> Unit
//) : BaseListAdapter<Board, RvItemBoardBinding>(itemClick, R.layout.rv_item_board)

class BoardListAdapter
    : RecyclerView.Adapter<BoardListAdapter.BoardViewHolder>() {

    interface OnBoardClickListener {
        fun onClickBoard(item: Board, position: Int)
    }

    private lateinit var boardClickListener: BoardListAdapter.OnBoardClickListener

    fun setOnBoardClickListener(listener: BoardListAdapter.OnBoardClickListener) {
        this.boardClickListener = listener
    }

    var boardList = ArrayList<Board>()

    override fun getItemCount(): Int = boardList.size

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): BoardListAdapter.BoardViewHolder {
        val binding: RvItemBoardBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_board,
            parent,
            false
        )

        return BoardViewHolder(binding)
    }

    override fun onBindViewHolder(holder: BoardListAdapter.BoardViewHolder, position: Int) {
        holder.bind(boardList[position], position)
    }

    inner class BoardViewHolder(
        private val binding: RvItemBoardBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Board, position: Int) {
            binding.setVariable(BR.item, item)
            binding.root.setOnClickListener {
                boardClickListener.onClickBoard(item, position)
            }

            // 새로운 게시물이 있는 경우
            if (item.newPost == "true") {
                binding.ivNewPost.visibility = View.VISIBLE
            }

            binding.executePendingBindings()
        }
    }

    fun addBoardList(boardList: List<Board>) {
        this.boardList.clear()
        this.boardList.addAll(boardList)
        notifyDataSetChanged()
    }

    fun updateItem(board: Board, position: Int) {
        boardList[position] = board
        notifyItemChanged(position)
    }
}