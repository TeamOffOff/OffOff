package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.graphics.Rect
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostBinding
import com.yuuuzzzin.offoff_android.service.models.Comment
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.service.models.Reply
import com.yuuuzzzin.offoff_android.utils.*
import com.yuuuzzzin.offoff_android.utils.Constants.DELETE_COMMENT
import com.yuuuzzzin.offoff_android.utils.Constants.REPORT_COMMENT
import com.yuuuzzzin.offoff_android.utils.DialogUtils.showAutoCloseDialog
import com.yuuuzzzin.offoff_android.utils.DialogUtils.showYesNoDialog
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostViewModel
import com.yuuuzzzin.offoff_android.views.adapter.CommentListAdapter
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable
import java.io.Serializable

@AndroidEntryPoint
class PostActivity : BaseActivity<ActivityPostBinding>(R.layout.activity_post) {

    private val viewModel: PostViewModel by viewModels()

    private lateinit var commentListAdapter: CommentListAdapter
    private lateinit var currentCommentList: Array<Comment>

    lateinit var postId: String
    lateinit var boardType: String
    private lateinit var boardName: String
    private var post: Post? = null
    private var postPosition: Int = 0
    private var commentPosition: Int = 0
    var parentReplyId: String? = null

    private var requestUpdate: Boolean? = false
    private var isFirst: Boolean = true

    private lateinit var writeIcon: FontDrawable
    private lateinit var likeIcon: FontDrawable

    // 게시물 수정 액티비티 요청 및 결과 처리
    private val requestEditPost = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        val resultCode = activityResult.resultCode // 결과 코드
        // val data = activityResult.data // 인텐트 데이터

        if (resultCode == Activity.RESULT_OK) {
            viewModel.getPost(postId, boardType)
            requestUpdate = true
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        processIntent()
        initViewModel()
        initToolbar()
        initView()
        initRV()
    }

    private fun processIntent() {
        postId = intent.getStringExtra("id").toString()
        postPosition = intent.getIntExtra("position", 0)
        boardType = intent.getStringExtra("boardType").toString()
        boardName = intent.getStringExtra("boardName").toString()
        //currentPostList = intent.getSerializableExtra("postList") as Array<Post>

        viewModel.getPost(postId, boardType)
        viewModel.getComments(postId, boardType)
    }

    private fun initViewModel() {
        binding.activity = this
        binding.viewModel = viewModel

        viewModel.post.observe(binding.lifecycleOwner!!, {
            binding.post = it
            this.post = it
            binding.refreshLayout.isRefreshing = false
            if (isFirst) {
                invalidateOptionsMenu()
            }
        })

        viewModel.successLike.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showSuccessLikeDialog(it)
                requestUpdate = true
            }
        })

        viewModel.alreadyLike.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showAlreadyLikeDialog(it)
            }
        })

        //viewModel.getComments(postId, boardType)
        viewModel.commentList.observe(binding.lifecycleOwner!!, {
            with(commentListAdapter) { submitList(it.toMutableList()) }
            currentCommentList = it.toTypedArray()
            if (!isFirst) {
                post?.replyCount = it.size
            }
            isFirst = false
            binding.refreshLayout.isRefreshing = false
        })

        viewModel.comment.observe(binding.lifecycleOwner!!, {
            currentCommentList[commentPosition] = it
            viewModel.update(currentCommentList)
        })

        viewModel.reply.observe(binding.lifecycleOwner!!, {
            commentListAdapter.replyListAdapter.updateItem(
                it,
                commentPosition!!
            )
        })

        viewModel.replySuccessEvent.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                parentReplyId = null
            }
        })

        viewModel.showReplyOptionDialog.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showReplyOptionDialog(it, isMine = false)
            }
        })

        viewModel.showMyReplyOptionDialog.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showReplyOptionDialog(it, isMine = true)
            }
        })
    }

    private fun initToolbar() {
        val toolbar: MaterialToolbar = binding.appbar

        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = boardName

            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_baseline_arrow_back_24)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun initView() {
        writeIcon = FontDrawable(this, R.string.fa_pen_solid, true, false)
        writeIcon.setTextColor(ContextCompat.getColor(this, R.color.green))

        likeIcon = FontDrawable(this, R.string.fa_thumbs_up_solid, true, false)
        likeIcon.setTextColor(ContextCompat.getColor(this, R.color.red))

        binding.tfComment.endIconDrawable = writeIcon

        binding.tfComment.setEndIconOnClickListener {
            if (!binding.etComment.text.isNullOrBlank()) {
                if (parentReplyId.isNullOrBlank()) {
                    viewModel.writeComment(postId, boardType)
                } else {
                    viewModel.writeReply(postId, boardType, parentReplyId!!)
                }
                binding.etComment.text = null
                hideKeyboard()
                binding.nestedScrollView.post {
                    binding.nestedScrollView.fullScroll(View.FOCUS_DOWN)
                }
                requestUpdate = true
            }
        }

        binding.refreshLayout.isRefreshing = false

        binding.refreshLayout.setOnRefreshListener {
            viewModel.getPost(postId, boardType)
            viewModel.getComments(postId, boardType)
            isFirst = true
        }
    }

    private fun initRV() {
        commentListAdapter = CommentListAdapter(viewModel)

        binding.rvComment.apply {
            adapter = commentListAdapter
            layoutManager = LinearLayoutManager(context)
            isNestedScrollingEnabled = false
        }

        commentListAdapter.setOnCommentClickListener(object :
            CommentListAdapter.OnCommentClickListener {
            override fun onClickCommentOption(comment: Comment) {
                if (OffoffApplication.user.id == comment.author.id) {
                    showCommentOptionDialog(comment.id, true)
                } else {
                    showCommentOptionDialog(comment.id, isMine = false)
                }
            }

            override fun onLikeComment(position: Int, comment: Comment) {
                commentPosition = position
                viewModel.likeComment(comment.id, boardType)
            }

            override fun onWriteReply(comment: Comment) {
                parentReplyId = comment.id
                binding.etComment.isFocusableInTouchMode = true
                binding.etComment.requestFocusAndShowKeyboard(this@PostActivity)
            }

            override fun onLikeReply(position: Int, reply: Reply) {
                commentPosition = position
                viewModel.likeReply(reply.id!!, boardType)
            }
        })
    }

    // 게시물 삭제 다이얼로그
    private fun showDeletePostDialog(message: String) {
        showYesNoDialog(this, message, onPositiveClick = { dialog, which ->
            viewModel.deletePost(postId, boardType)

            val intent = Intent(applicationContext, BoardActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
            intent.putExtra("boardType", boardType)
            intent.putExtra("boardName", boardName)
            startActivity(intent)
            finish()
        },
            onNegativeClick = { dialog, which ->
                null
            })
    }

    // 좋아요 성공 다이얼로그
    private fun showSuccessLikeDialog(message: String) {
        showAutoCloseDialog(this, message)
    }

    // 이미 좋아요를 한 경우의 다이얼로그
    private fun showAlreadyLikeDialog(message: String) {
        DialogUtils.showYesDialog(this, message)
    }

    // 댓글 삭제 다이얼로그
    private fun showCommentDeleteDialog(commentId: String) {
        showYesNoDialog(this, "댓글을 삭제하시겠습니까?", onPositiveClick = { dialog, which ->
            viewModel.deleteComment(commentId, postId, boardType)
        },
            onNegativeClick = { dialog, which ->
                null
            })
    }

    // 대댓글 삭제 다이얼로그
    private fun showReplyDeleteDialog(reply: Reply) {
        showYesNoDialog(this, "댓글을 삭제하시겠습니까?", onPositiveClick = { dialog, which ->
            viewModel.deleteReply(reply.id!!, postId, boardType, reply.parentReplyId!!)
        },
            onNegativeClick = { dialog, which ->
                null
            })
    }

    override fun onBackPressed() {
        if (intent.getIntExtra("postWriteType", PostWriteType.WRITE) == PostWriteType.WRITE) {
            val intent = Intent(applicationContext, BoardActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
            intent.putExtra("boardType", boardType)
            intent.putExtra("boardName", boardName)
            startActivity(intent)
        } else if (intent.getIntExtra("postWriteType", PostWriteType.WRITE) == PostWriteType.EDIT) {
            val intent = Intent()
            intent.putExtra("post", this.post as Serializable)
            setResult(RESULT_OK, intent)
        } else if (requestUpdate == true) {
            Log.d("tag_onBackPressed", "뒤로가기")
            val intent = Intent()
            intent.putExtra("post", this.post as Serializable)
            setResult(RESULT_OK, intent)
        }
        finish()
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_post, menu)

        if (OffoffApplication.user.id != post?.author?.id) {
            Log.d(
                "tag_id",
                "id : " + OffoffApplication.user.id + "/ author: " + post?.author?.id.toString()
            )
            menu!!.findItem(R.id.action_delete).isVisible = false
            menu.findItem(R.id.action_edit).isVisible = false
        }

        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_edit -> {
                // 수정 버튼 누를 시
                val intent = Intent(applicationContext, PostWriteActivity::class.java).apply {
                    putExtra("boardType", boardType)
                    putExtra("boardName", boardName)
                    putExtra("postWriteType", PostWriteType.EDIT)
                    putExtra("postId", postId)
                    putExtra("postTitle", binding.post!!.title)
                    putExtra("postContent", binding.post!!.content)
                }

                requestEditPost.launch(intent)
                true
            }
            R.id.action_delete -> {
                // 삭제 버튼 누를 시
                showDeletePostDialog("게시글을 삭제하시겠습니까?")

                true
            }
            R.id.action_report -> {
                // 신고 버튼 누를 시
                true
            }
            android.R.id.home -> {
                onBackPressed()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    // 댓글 옵션 다이얼로그
    private fun showCommentOptionDialog(id: String, isMine: Boolean) {

        val builder = AlertDialog.Builder(this)
        val array = if (isMine) arrayMine else arrayNotMine

        builder.setItems(array) { _, which ->
            val selected = array[which]

            try {
                when (selected) {
                    DELETE_COMMENT -> {
                        showCommentDeleteDialog(id)
                        requestUpdate = true
                        true
                    }
                    REPORT_COMMENT -> {
                        true
                    }
                }

            } catch (e: IllegalArgumentException) {

            }
        }

        builder.create().show()
    }

    // 대댓글 옵션 다이얼로그
    private fun showReplyOptionDialog(reply: Reply, isMine: Boolean) {

        val builder = AlertDialog.Builder(this)
        val array = if (isMine) arrayMine else arrayNotMine

        builder.setItems(array) { _, which ->
            val selected = array[which]

            try {
                when (selected) {
                    DELETE_COMMENT -> {
                        showReplyDeleteDialog(reply)
                        requestUpdate = true
                        true
                    }
                    REPORT_COMMENT -> {
                        true
                    }
                }

            } catch (e: IllegalArgumentException) {

            }
        }

        builder.create().show()
    }

    companion object {
        val arrayMine = arrayOf(
            DELETE_COMMENT
        )

        val arrayNotMine = arrayOf(
            REPORT_COMMENT
        )
    }

    override fun dispatchTouchEvent(motionEvent: MotionEvent?): Boolean {
        val focusView = binding.etComment
        if (focusView != null) {

            var rect = Rect()
            focusView.getGlobalVisibleRect(rect)
            val x = motionEvent!!.x.toInt()
            val y = motionEvent.y.toInt()
            if (!rect.contains(x, y)) {
                hideKeyboard()
                focusView.clearFocus()
                parentReplyId = null
            }
        }
        return super.dispatchTouchEvent(motionEvent)
    }
}