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
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostBinding
import com.yuuuzzzin.offoff_android.service.models.Comment
import com.yuuuzzzin.offoff_android.service.models.Image
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
import com.yuuuzzzin.offoff_android.views.adapter.PostImageAdapter
import dagger.hilt.android.AndroidEntryPoint
import java.io.Serializable

@AndroidEntryPoint
class PostActivity : BaseActivity<ActivityPostBinding>(R.layout.activity_post) {

    private val viewModel: PostViewModel by viewModels()

    private lateinit var commentListAdapter: CommentListAdapter
    private lateinit var currentCommentList: Array<Comment>

    private lateinit var postImageListAdapter: PostImageAdapter

    lateinit var postId: String
    lateinit var boardType: String
    private lateinit var boardName: String
    private var post: Post? = null
    private var postPosition: Int = 0
    private var commentPosition: Int = 0
    var parentReplyId: String? = null

    private var requestUpdate: Boolean? = false
    private var isFirst: Boolean = true

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

            if (!it.image.isNullOrEmpty()) {
                postImageListAdapter.addPostImageList(it.image.toMutableList())
                Log.d("tag_imageLIst", it.image.toMutableList().toString())
            }

            if (!it.author.profileImage.isNullOrEmpty()) {
                binding.ivAvatar.apply {
                    setImageBitmap(ImageUtils.stringToBitmap(it.author.profileImage[0].body.toString()))
                    clipToOutline = true
                }
            }

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

                // for문을 돌아 대댓글이 있는지 확인 후 replyCount에 더해주기
                var replyCount = 0

                for (i in it) {
                    if (i.childrenReplies != null)
                        replyCount += i.childrenReplies.size
                }

                post?.replyCount = it.size + replyCount
                binding.tvCommentsNum.text = post?.replyCount.toString()
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
                commentPosition
            )
        })

        viewModel.replySuccessEvent.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                Log.d("tag_reply", "대댓글작성")
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

        binding.btWrite.setOnClickListener {

            if (!binding.etComment.text.isNullOrBlank()) {
                if (parentReplyId.isNullOrBlank()) {
                    isFirst = false
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
    }

    private fun initToolbar() {
        val toolbar: MaterialToolbar = binding.toolbar
        toolbar.overflowIcon = getDrawable(R.drawable.ic_more_option)

        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = boardName

            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun initView() {
        binding.refreshLayout.isRefreshing = false

        binding.refreshLayout.setOnRefreshListener {
            viewModel.getPost(postId, boardType)
            viewModel.getComments(postId, boardType)
            isFirst = true
        }
    }

    private fun initRV() {
        commentListAdapter = CommentListAdapter(viewModel)
        postImageListAdapter = PostImageAdapter()

        val spaceDecorationComment = RecyclerViewUtils.VerticalSpaceItemDecoration(7) // 아이템 사이의 거리
        binding.rvComment.apply {
            adapter = commentListAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecorationComment)
            isNestedScrollingEnabled = false
        }

        val spaceDecorationImage = RecyclerViewUtils.VerticalSpaceItemDecoration(20) // 아이템 사이의 거리
        binding.rvImage.apply {
            adapter = postImageListAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecorationImage)
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

        postImageListAdapter.setOnPostImageClickListener(object :
            PostImageAdapter.OnPostImageClickListener {
            override fun onClickPostImage(item: Image, position: Int) {
                TODO("Not yet implemented")
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
        when {
            intent.getIntExtra("postWriteType", -1) == PostWriteType.WRITE -> {
                val intent = Intent(applicationContext, BoardActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                intent.putExtra("boardType", boardType)
                intent.putExtra("boardName", boardName)
                startActivity(intent)
            }
            intent.getIntExtra("postWriteType", -1) == PostWriteType.EDIT -> {
                val intent = Intent()
                intent.putExtra("post", this.post as Serializable)
                setResult(Activity.RESULT_OK, intent)
            }
            requestUpdate == true -> {
                val intent = Intent()
                intent.putExtra("post", this.post as Serializable)
                setResult(Activity.RESULT_OK, intent)
            }
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
                //parentReplyId = null
            }
        }

        return super.dispatchTouchEvent(motionEvent)
    }
}