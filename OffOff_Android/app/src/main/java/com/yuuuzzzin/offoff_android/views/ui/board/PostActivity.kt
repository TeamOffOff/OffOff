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
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.LinearLayoutManager
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
import com.yuuuzzzin.offoff_android.utils.Constants.convertDPtoPX
import com.yuuuzzzin.offoff_android.utils.Constants.getBoardName
import com.yuuuzzzin.offoff_android.utils.DateUtils.convertStringToLocalDate
import com.yuuuzzzin.offoff_android.utils.DialogUtils.showAutoCloseDialog
import com.yuuuzzzin.offoff_android.utils.DialogUtils.showYesNoDialog
import com.yuuuzzzin.offoff_android.utils.KeyboardUtils.hideKeyboard
import com.yuuuzzzin.offoff_android.utils.KeyboardUtils.requestFocusAndShowKeyboard
import com.yuuuzzzin.offoff_android.utils.ScrollViewUtils.smoothScrollToView
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostViewModel
import com.yuuuzzzin.offoff_android.views.adapter.CommentListAdapter
import com.yuuuzzzin.offoff_android.views.adapter.PostImageAdapter
import dagger.hilt.android.AndroidEntryPoint
import java.io.Serializable

@AndroidEntryPoint
class PostActivity : BaseActivity<ActivityPostBinding>(R.layout.activity_post) {

    private val viewModel: PostViewModel by viewModels()
    private lateinit var keyboardVisibilityUtils: KeyboardUtils.KeyboardVisibilityUtils

    private lateinit var commentListAdapter: CommentListAdapter
    private lateinit var currentCommentList: Array<Comment>
    private lateinit var postImageListAdapter: PostImageAdapter

    lateinit var postId: String
    lateinit var boardType: String
    private lateinit var boardName: String
    private var post: Post? = null
    private var postPosition: Int = 0
    private var commentPosition: Int = 0
    private var selectedCommentPosition: Int? = null
    private var replyPosition: Int = 0
    private var parentReplyId: String? = null
    private var requestUpdate: Boolean? = false
    private var isFirst: Boolean = true
    private var imageList: List<Image>? = null

    // 게시물 수정 액티비티 요청 및 결과 처리
    private val requestEditPost = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        val resultCode = activityResult.resultCode // 결과 코드

        if (resultCode == Activity.RESULT_OK) {
            viewModel.getPost(postId, boardType, false)
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
        boardName = getBoardName(boardType)
    }

    private fun initViewModel() {
        binding.activity = this
        binding.viewModel = viewModel

        // 포스트 & 댓글 요청
        viewModel.getPost(postId, boardType, false)
        viewModel.getComments(postId, boardType, false)
        //viewModel.getPostImages(postId, boardType)

//        viewModel.isSuccess.observe(binding.lifecycleOwner!!, {
//            if(it)
//                binding.layoutProgress.root.visibility = View.GONE
//        })

        // 로딩 화면 가시화 여부
        viewModel.loading.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    binding.layoutProgress.root.visibility = View.VISIBLE
                } else {
                    binding.layoutProgress.root.visibility = View.GONE
                }
            }
        })

        viewModel.post.observe(binding.lifecycleOwner!!, {
            binding.post = it
            binding.tvDate.text = DateUtils.dateFormatter.format(convertStringToLocalDate(it.date))

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

        // 게시글 좋아요 처리
        viewModel.isLikedPost.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    val likesNum = binding.tvLikesNum.text.toString()
                    showAutoCloseDialog(this, "좋아요를 눌렀습니다.")
                    binding.tvLikesNum.text = (likesNum.toInt() + 1).toString()
                    post!!.likes!!.add(OffoffApplication.user.id)
                    requestUpdate = true
                } else {
                    showAutoCloseDialog(this, "이미 좋아요를 누른 게시글입니다.")
                }
            }
        })

        // 댓글 좋아요 처리
        viewModel.isLikedComment.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    showAutoCloseDialog(this, "좋아요를 눌렀습니다.")
                } else {
                    showAutoCloseDialog(this, "이미 좋아요를 누른 댓글입니다.")
                }
            }
        })

        // 게시글 스크랩 처리
        viewModel.isBookmarkedPost.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                val scrapNum = binding.tvScrapNum.text.toString()
                if (it) {
                    showAutoCloseDialog(this, "게시글을 스크랩했습니다.")
                    binding.tvScrapNum.text = (scrapNum.toInt() + 1).toString()
                } else {
                    showAutoCloseDialog(this, "게시글 스크랩을 취소했습니다.")
                    binding.tvScrapNum.text = (scrapNum.toInt() - 1).toString()
                }
            }
        })

        // 게시글 신고 처리
        viewModel.isReportedPost.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    showAutoCloseDialog(this, "게시글을 신고했습니다.")
                } else {
                    showAutoCloseDialog(this, "게시글 신고를 취소했습니다.")
                }
            }
        })

        // 댓글 요청 처리
        viewModel.commentList.observe(binding.lifecycleOwner!!, {
            with(commentListAdapter) { addCommentList(it.toMutableList()) }
            currentCommentList = it.toTypedArray()

            if (!isFirst)
                calculateCommentNum(it)

            isFirst = false
            binding.refreshLayout.isRefreshing = false
        })

        // 새로 작성된 댓글 처리
        viewModel.newCommentList.observe(binding.lifecycleOwner!!, {
            with(commentListAdapter) { addCommentList(it.toMutableList()) }
            currentCommentList = it.toTypedArray()

            if (!isFirst)
                calculateCommentNum(it)

            isFirst = false
            binding.refreshLayout.isRefreshing = false

            // 해당 댓글로 스크롤 이동
            binding.rvComment.post {
                val y =
                    binding.rvComment.y + binding.rvComment.getChildAt(commentListAdapter.itemCount - 1).y
                binding.nestedScrollView.smoothScrollTo(0, y.toInt())
            }
        })

        // 새로 작성된 대댓글 처리
        viewModel.replyList.observe(binding.lifecycleOwner!!, {
            with(commentListAdapter) { addCommentList(it.toMutableList()) }
            currentCommentList = it.toTypedArray()

            if (!isFirst)
                calculateCommentNum(it)

            isFirst = false
            binding.refreshLayout.isRefreshing = false

            // 해당 댓글로 스크롤 이동
            if (commentPosition >= commentListAdapter.itemCount - 1) {
                binding.rvComment.post {
                    val y = binding.rvComment.bottom
                    binding.nestedScrollView.smoothScrollTo(0, y)
                }
            } else {
                binding.rvComment.post {
                    binding.nestedScrollView.smoothScrollToView(
                        binding.rvComment.getChildAt(
                            commentPosition + 1
                        ), 360
                    )
                }
            }
        })

        // 댓글 좋아요 처리
        viewModel.comment.observe(binding.lifecycleOwner!!, {
            currentCommentList[commentPosition] = it
            viewModel.update(currentCommentList)
        })

        // 대댓글 좋아요 처리
        viewModel.reply.observe(binding.lifecycleOwner!!, {
            commentListAdapter.commentList[commentPosition].childrenReplies!![replyPosition].likes!!.add(
                OffoffApplication.user.id
            )
            commentListAdapter.notifyDataSetChanged()
//            binding.rvComment.findViewHolderForAdapterPosition(commentPosition).replyListAdapter.updateItem(
//                it,
//                commentPosition
//            )
        })

        // 대댓글 작성 성공 처리
        viewModel.replySuccessEvent.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                parentReplyId = null
                selectedCommentPosition = null
            }
        })

        // 대댓글 옵션 다이얼로그 처리
        viewModel.showReplyOptionDialog.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
//                showReplyOptionDialog(it, isMine = false)
                showReplyOptionDialog(it, isMine = true)
            }
        })

        // 내 대댓글 옵션 다이얼로그 처리
        viewModel.showMyReplyOptionDialog.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showReplyOptionDialog(it, isMine = true)
            }
        })

        // 이미지 리스트 처리
//        viewModel.imageList.observe(binding.lifecycleOwner!!, {
//            imageList = it
//            OffoffApplication.imageList = it
//        })

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
                requestUpdate = true
            }
        }
    }

    private fun initToolbar() {
        val toolbar: Toolbar = binding.toolbar
        toolbar.overflowIcon = ResUtils.getDrawable(R.drawable.ic_more_option_resized)

        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = boardName

            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white_resized)
        }
    }

    private fun initView() {
        binding.refreshLayout.isRefreshing = false

        binding.refreshLayout.setOnRefreshListener {
            viewModel.getPost(postId, boardType, true)
            viewModel.getComments(postId, boardType, true)
            isFirst = true
        }

        keyboardVisibilityUtils = KeyboardUtils.KeyboardVisibilityUtils(window,
            onHideKeyboard = {
                binding.layout.run {
                    //키보드 내려갔을때 원하는 동작
                    //commentListAdapter.notifyDataSetChanged()
                    if (selectedCommentPosition != null) {
                        Log.d("tag_reply", selectedCommentPosition.toString())
                        commentListAdapter.notifyItemChanged(selectedCommentPosition!!)
                        parentReplyId = null
                    }
                }
            }
        )
    }

    private fun initRV() {
        commentListAdapter = CommentListAdapter(viewModel)
        postImageListAdapter = PostImageAdapter()

        val spaceDecorationComment =
            RecyclerViewUtils.VerticalSpaceItemDecoration(convertDPtoPX(this, 7)) // 아이템 사이의 거리
        binding.rvComment.apply {
            adapter = commentListAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecorationComment)
            hasFixedSize()
            isNestedScrollingEnabled = false
        }

        val spaceDecorationImage =
            RecyclerViewUtils.VerticalSpaceItemDecoration(convertDPtoPX(this, 16)) // 아이템 사이의 거리
        binding.rvImage.apply {
            adapter = postImageListAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecorationImage)
            hasFixedSize()
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

            override fun onWriteReply(position: Int, comment: Comment) {
                if (selectedCommentPosition != null) {
                    commentListAdapter.notifyItemChanged(selectedCommentPosition!!)
                }

                parentReplyId = comment.id
                commentPosition = position
                selectedCommentPosition = position
                binding.etComment.isFocusableInTouchMode = true
                binding.etComment.requestFocusAndShowKeyboard(this@PostActivity)

                // 선택한 댓글이 키보드 위로 보이도록
                binding.rvComment.post {
                    binding.nestedScrollView.smoothScrollToView(
                        binding.rvComment.getChildAt(
                            commentPosition
                        ), 360
                    )
                }
            }

            override fun onLikeReply(position: Int, parentPosition: Int, reply: Reply) {
                commentPosition = parentPosition
                replyPosition = position
                viewModel.likeReply(reply.id!!, boardType)
            }
        })

        postImageListAdapter.setOnPostImageClickListener(object :
            PostImageAdapter.OnPostImageClickListener {
            override fun onClickPostImage(item: Image, position: Int) {
                val intent = Intent(this@PostActivity, ImageSlideActivity::class.java)
                intent.putExtra("position", position)
                intent.putExtra("boardType", boardType)
                intent.putExtra("postId", postId)
                startActivity(intent)
            }
        })
    }

    // 댓글 개수 계산
    private fun calculateCommentNum(list: List<Comment>) {

        // for문을 돌아 대댓글이 있는지 확인 후 replyCount 에 더해주기
        var replyCount = 0

        for (i in list) {
            if (i.childrenReplies != null)
                replyCount += i.childrenReplies.size
        }

        post?.replyCount = list.size + replyCount
        binding.tvCommentsNum.text = post?.replyCount.toString()
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

    override fun dispatchTouchEvent(motionEvent: MotionEvent?): Boolean {
        val focusView = binding.layoutEditComment
        if (focusView != null) {

            val rect = Rect()
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

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_post, menu)

        Log.d(
            "tag_id",
            "id : " + OffoffApplication.user.id + "/ author: " + post?.author?.id.toString()
        )

        if (OffoffApplication.user.id != post?.author?.id) {
            menu!!.findItem(R.id.action_delete).isVisible = false
            menu.findItem(R.id.action_edit).isVisible = false
        } else {
            menu!!.findItem(R.id.action_report).isVisible = false
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
                    putExtra("post", post as Serializable)
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
                showYesNoDialog(this, "게시글을 신고하시겠습니까?", onPositiveClick = { dialog, which ->
                    viewModel.reportPost(postId, boardType)
                },
                    onNegativeClick = { dialog, which ->
                        null
                    })
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
                        showYesNoDialog(this,
                            "댓글을 삭제하시겠습니까?",
                            onPositiveClick = { dialog, which ->
                                viewModel.deleteComment(id, postId, boardType)
                            },
                            onNegativeClick = { dialog, which ->
                                null
                            })
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

        builder.setTitle("메뉴")
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
                        showYesNoDialog(this,
                            "댓글을 삭제하시겠습니까?",
                            onPositiveClick = { dialog, which ->
                                viewModel.deleteReply(
                                    reply.id!!,
                                    postId,
                                    boardType,
                                    reply.parentReplyId!!
                                )
                            },
                            onNegativeClick = { dialog, which ->
                                null
                            })
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

        builder.setTitle("메뉴")
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
}