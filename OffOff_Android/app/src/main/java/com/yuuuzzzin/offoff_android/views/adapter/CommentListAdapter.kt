package com.yuuuzzzin.offoff_android.views.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.RvItemCommentBinding
import com.yuuuzzzin.offoff_android.service.models.Comment
import com.yuuuzzzin.offoff_android.service.models.Reply
import com.yuuuzzzin.offoff_android.utils.ImageUtils
import com.yuuuzzzin.offoff_android.utils.ResUtils.getDrawable
import com.yuuuzzzin.offoff_android.viewmodel.PostViewModel

class CommentListAdapter(private val viewModel: PostViewModel) :
    RecyclerView.Adapter<CommentListAdapter.CommentViewHolder>() {


    interface OnCommentClickListener {
        fun onClickCommentOption(comment: Comment)
        fun onLikeComment(position: Int, comment: Comment)
        fun onWriteReply(position: Int, comment: Comment)
        fun onLikeReply(position: Int, parentPosition: Int, reply: Reply)
    }

    private lateinit var commentClickListener: OnCommentClickListener

    fun setOnCommentClickListener(listener: OnCommentClickListener) {
        this.commentClickListener = listener
    }

    var commentList = ArrayList<Comment>()

    override fun getItemCount(): Int = commentList.size

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CommentViewHolder {
        val binding: RvItemCommentBinding = DataBindingUtil.inflate(
            LayoutInflater.from(parent.context),
            R.layout.rv_item_comment,
            parent,
            false
        )

        return CommentViewHolder(binding)
    }

    override fun onBindViewHolder(holder: CommentListAdapter.CommentViewHolder, position: Int) {
        holder.bind(commentList[position], position, viewModel)
    }

    inner class CommentViewHolder(
        private val binding: RvItemCommentBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: Comment, position: Int, viewModel: PostViewModel) {
            lateinit var replyListAdapter: ReplyListAdapter
            binding.setVariable(BR.item, item)
            if (!item.author.profileImage.isNullOrEmpty()) {
                binding.ivAvatar.apply {
                    setImageBitmap(ImageUtils.stringToBitmap(item.author.profileImage[0].body.toString()))
                    clipToOutline = true
                }
            }
            binding.layoutComment.background = getDrawable(R.drawable.layout_comment)
            binding.executePendingBindings()
            binding.btLikes.setOnClickListener {
                commentClickListener.onLikeComment(position, item)
            }

            if (item.childrenReplies != null) {
                replyListAdapter = ReplyListAdapter(position)
                replyListAdapter.addReplyList(item.childrenReplies as ArrayList<Reply>)
                replyListAdapter.notifyDataSetChanged()

                binding.rvReply.apply {
                    adapter = replyListAdapter
                    layoutManager = LinearLayoutManager(binding.root.context)
                    hasFixedSize()
                }

                replyListAdapter.setOnReplyClickListener(object :
                    ReplyListAdapter.OnReplyClickListener {

                    override fun onClickOption(reply: Reply, position: Int) {
                        if (OffoffApplication.user.id == reply.author!!.id) {
                            viewModel.showMyReplyOptionDialog(reply)
                        } else {
                            viewModel.showReplyOptionDialog(reply)
                        }
                    }

                    override fun onLikeReply(position: Int, parentPosition: Int, reply: Reply) {
                        commentClickListener.onLikeReply(position, parentPosition, reply)
                    }
                })
            }

            binding.btCommentOption.setOnClickListener {
                commentClickListener.onClickCommentOption(item)
            }

            binding.btReply.setOnClickListener {
                binding.layoutComment.background = getDrawable(R.drawable.layout_comment_selected)
                commentClickListener.onWriteReply(position, item)
            }
        }
    }

    fun clearItems() {
        this.commentList.clear()
        notifyDataSetChanged()
    }

    fun updateItem(comment: Comment, position: Int) {
        commentList[position] = comment
        notifyItemChanged(position)
    }

    fun addCommentList(commentList: List<Comment>) {
        this.commentList.clear()
        this.commentList.addAll(commentList)
        notifyDataSetChanged()
    }
}