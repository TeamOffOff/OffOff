package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.inputmethod.InputMethodManager
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
import com.yuuuzzzin.offoff_android.utils.Constants.DELETE_COMMENT
import com.yuuuzzzin.offoff_android.utils.Constants.REPORT_COMMENT
import com.yuuuzzzin.offoff_android.utils.PostWriteType
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostViewModel
import com.yuuuzzzin.offoff_android.views.adapter.CommentListAdapter
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.io.Serializable

@AndroidEntryPoint
class PostActivity : BaseActivity<ActivityPostBinding>(R.layout.activity_post) {

    private val viewModel: PostViewModel by viewModels()
    lateinit var postId: String
    private lateinit var boardName: String
    lateinit var boardType: String
    private var postPosition: Int = 0
    private var commentPosition: Int = 0
    //private var author: String? = null
    private var doLike: Boolean? = false
    private lateinit var currentCommentList: Array<Comment>
    private var post: Post ?= null
    private lateinit var writeIcon: FontDrawable
    private lateinit var likeIcon: FontDrawable
    private lateinit var commentListAdapter: CommentListAdapter
    private var isFirst: Boolean = true

    // 게시물 수정 액티비티 요청 및 결과 처리
    private val requestEditPost = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        val resultCode = activityResult.resultCode // 결과 코드
        // val data = activityResult.data // 인텐트 데이터

        if (resultCode == Activity.RESULT_OK) {
            viewModel.getPost(postId, boardType)
            doLike = true
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
    }

    private fun initViewModel() {
        binding.activity = this
        binding.viewModel = viewModel

        viewModel.post.observe(binding.lifecycleOwner!!, {
            binding.post = it
            this.post = it
            binding.refreshLayout.isRefreshing = false
            invalidateOptionsMenu()
        })

        viewModel.newPost.observe(binding.lifecycleOwner!!, {
            binding.post = it
            this.post = it

            //currentPostList?.set(postPosition, it)
        })

//        viewModel.author.observe(binding.lifecycleOwner!!, {
//            author = it
//            Log.d(
//                "tag_id",
//                "id : " + OffoffApplication.user.id + " / author: " + author.toString()
//            )
//            invalidateOptionsMenu()
//        })

        viewModel.successLike.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showSuccessLikeDialog(it)
                doLike = true
            }
        })

        viewModel.alreadyLike.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showAlreadyLikeDialog(it)
            }
        })

        viewModel.getComments(postId, boardType)
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
            Log.d("tag_item_", "$it")
            currentCommentList[commentPosition] = it
            viewModel.update(currentCommentList)
        })

        viewModel.commentSuccessEvent.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {

            }
        })

        viewModel.showCommentDialog.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showCommentOptionDialog(it)
            }
        })

        viewModel.showMyCommentDialog.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showMyCommentOptionDialog(it)
            }
        })

        viewModel.showMyCommentDialog.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showMyCommentOptionDialog(it)
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
                if (viewModel.parentReplyId == null) {
                    viewModel.writeComment(postId, boardType)
                } else {
                    viewModel.writeReply(postId, boardType)
                }
                binding.etComment.text = null
                hideKeyboard()
                binding.nestedScrollView.post {
                    binding.nestedScrollView.fullScroll(View.FOCUS_DOWN)
                }
                doLike = true
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

        commentListAdapter.setOnLikeCommentListener(object :
            CommentListAdapter.OnLikeCommentListener {
            override fun onLikeComment(position: Int, comment: Comment) {
                commentPosition = position
                viewModel.likeComment(comment.id, boardType)
            }
        })

        commentListAdapter.setOnClickCommentOptionListener(object :
            CommentListAdapter.OnClickCommentOptionListener {
            override fun onClickCommentOption(comment: Comment) {
                if (OffoffApplication.user.id == comment.author.id) {
                    viewModel.showMyCommentDialog(comment.id)
                } else {
                    viewModel.showCommentDialog(comment.id)
                }
            }
        })

        commentListAdapter.setOnWriteReplyListener(object :
            CommentListAdapter.OnWriteReplyListener {
            override fun onWriteReply(comment: Comment) {
                Log.d("tag_parentReply", comment.id)
                viewModel.parentReplyId = comment.id
                binding.etComment.isFocusableInTouchMode = true
                binding.etComment.requestFocus()
                showKeyboard()
            }
        })
    }

    private fun showDeleteDialog(message: String) {
        val dialog = AlertDialog.Builder(this)
        dialog.setMessage(message)
        dialog.setIcon(android.R.drawable.ic_dialog_alert)
        dialog.setPositiveButton("예") { dialog, which ->
            viewModel.deletePost(postId, boardType)

            val intent = Intent(applicationContext, BoardActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
            intent.putExtra("boardType", boardType)
            intent.putExtra("boardName", boardName)
            startActivity(intent)
            finish()
        }
        dialog.setNegativeButton("아니오", null)
        dialog.show()
    }

    private fun showSuccessLikeDialog(message: String) {
        val dialog = AlertDialog.Builder(this).create()
        dialog.setMessage(message)
        // dialog.setNegativeButton("확인", null)
        CoroutineScope(Dispatchers.Main).launch {
            dialog.show()
            delay(1000)
            dialog.dismiss()
        }
    }

    private fun showAlreadyLikeDialog(message: String) {
        val dialog = AlertDialog.Builder(this)
        dialog.setMessage(message)
        dialog.setIcon(android.R.drawable.ic_dialog_alert)
        dialog.setNegativeButton("확인", null)
        dialog.show()
    }

    private fun hideKeyboard() {
        val imm: InputMethodManager =
            getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(currentFocus?.windowToken, 0)
    }

    private fun showKeyboard() {
        val imm: InputMethodManager =
            getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0)
    }

    private fun showMyCommentOptionDialog(commentId: String) {

        val array = arrayOf(
            DELETE_COMMENT,
            REPORT_COMMENT
        )
        val builder = AlertDialog.Builder(this)

        builder.setItems(array) { _, which ->
            val selected = array[which]

            try {
                when (which) {
                    0 -> {
                        showCommentDeleteDialog(commentId)
                        doLike = true
                        true
                    }
                    1 -> {
                        true
                    }
                }

            } catch (e: IllegalArgumentException) {

            }
        }

        val dialog = builder.create()
        dialog.show()
    }

    private fun showCommentOptionDialog(commentId: String) {

        val array = arrayOf(
            REPORT_COMMENT
        )
        val builder = AlertDialog.Builder(this)

        builder.setItems(array) { _, which ->
            val selected = array[which]

            try {
                when (which) {
                    0 -> {
                        true
                    }
                }

            } catch (e: IllegalArgumentException) {

            }
        }

        val dialog = builder.create()
        dialog.show()
    }

    private fun showCommentDeleteDialog(commentId: String) {
        val dialog = AlertDialog.Builder(this)
        dialog.setMessage("댓글을 삭제하시겠습니까?")
        dialog.setIcon(android.R.drawable.ic_dialog_alert)
        dialog.setPositiveButton("예") { dialog, which ->
            viewModel.deleteComment(commentId, postId, boardType)
        }
        dialog.setNegativeButton("아니오", null)
        dialog.show()
    }

    private fun showReplyDeleteDialog(id: String) {
        val dialog = AlertDialog.Builder(this)
        dialog.setMessage("댓글을 삭제하시겠습니까?")
        dialog.setIcon(android.R.drawable.ic_dialog_alert)
        dialog.setPositiveButton("예") { dialog, which ->
            viewModel.deleteReply(id, postId, boardType)
        }
        dialog.setNegativeButton("아니오", null)
        dialog.show()
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
        } else if (doLike == true) {
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
                showDeleteDialog("게시글을 삭제하시겠습니까?")

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

//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//        if (requestCode == 1) {
//            Log.d("tag_like", "requestCode")
//            if (resultCode == RESULT_OK) {
//                viewModel.getPost(postId, boardType)
//                doLike = true
//            }
//        }
//    }
}