package com.yuuuzzzin.offoff_android.view.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.databinding.RvItemBoardBinding
import com.yuuuzzzin.offoff_android.service.models.Board

class BoardListAdapter() : RecyclerView.Adapter<BoardListAdapter.BoardListViewHolder>() {

    lateinit var binding: RvItemBoardBinding

    var boardList = mutableListOf<Board>()

    // 어떤 View를 생성할 것인지
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BoardListViewHolder {
        binding = RvItemBoardBinding.inflate(LayoutInflater.from(parent.context), parent, false)

        return BoardListViewHolder(binding)
    }

    // 생성된 View에 어떤 데이터를 넣을 것인지
    override fun onBindViewHolder(holder: BoardListViewHolder, position: Int) {
        holder.onBind(boardList[position])
    }

    // 몇 개의 목록을 만들 것인지
    override fun getItemCount(): Int {
        return boardList.size
    }

    /*리사이클러뷰 아이템 클릭시 BookDetailActivity로 이동하기 위한 book click listener 정의*/
    interface OnBoardClickListener {
        fun onBoardClick(view: View, board: Board)
    }

    private lateinit var boardClickListener: OnBoardClickListener

    fun setOnBoardClickListener(listener: OnBoardClickListener) {
        this.boardClickListener = listener
    }

    // 리스트의 개별 항목 레이아웃을 포함하는 View 래퍼로, 각 목록 레이아웃에 필요한 기능들을 구현하는 곳
    // ex) 아이템 레이아웃의 버튼이 있는 경우 버튼 리스너 Holer 클래스에서 구현
    // val 예약어로 binding을 전달 받아 전역으로 사용
    // 상속받는 ViewHolder 생성자에서는 꼭 binding.root를 전달해야 함.
    inner class BoardListViewHolder(private val binding : RvItemBoardBinding) : RecyclerView.ViewHolder(binding.root) {
        fun onBind(board: Board) {
            binding.tvTitle.text = board.title
            binding.ivIcon.setImageResource(board.icon)

            itemView.setOnClickListener {
                boardClickListener.onBoardClick(itemView, board)
            }
        }
    }
}