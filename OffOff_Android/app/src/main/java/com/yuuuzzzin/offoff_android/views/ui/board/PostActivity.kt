package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.activity.viewModels
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostBinding
import com.yuuuzzzin.offoff_android.service.models.Comment
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

@AndroidEntryPoint
class PostActivity : BaseActivity<ActivityPostBinding>(R.layout.activity_post) {

    private val viewModel: PostViewModel by viewModels()
    private lateinit var postId: String
    private lateinit var boardName: String
    private lateinit var boardType: String
    private var commentPosition: Int = 0
    private var author: String? = null
    private var doLike: Boolean? = false
    private lateinit var currentCommentList: Array<Comment>
    private lateinit var writeIcon: FontDrawable
    private lateinit var likeIcon: FontDrawable
    private lateinit var commentListAdapter: CommentListAdapter

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
        boardType = intent.getStringExtra("boardType").toString()
        boardName = intent.getStringExtra("boardName").toString()

        viewModel.postId = postId
        viewModel.boardType = boardType

        viewModel.getPost(postId, boardType).toString()
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        viewModel.response.observe(binding.lifecycleOwner!!, {
            binding.post = it
        })

        viewModel.author.observe(binding.lifecycleOwner!!, {
            author = it
            Log.d(
                "tag_idviewmodel",
                "id : " + OffoffApplication.user.id + " / author: " + author.toString()
            )
            invalidateOptionsMenu()
        })

        viewModel.successLike.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                showSuccessLikeDialog(it)
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
        })

        viewModel.comment.observe(binding.lifecycleOwner!!, {
            Log.d("tag_item_", "$it")
            currentCommentList[commentPosition] = it
            viewModel.update(currentCommentList)
            //commentListAdapter.updateComment(commentPosition!!, it)

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

//        viewModel.singleData.observe(this, { singleData ->
////            val index = commentListAdapter.
////            adapterList.indexOfFirst { singleData.id == it.id }
////            adapterList[index] = singleData
//            commentListAdapter.notifyItemChanged(index)
//        }
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
                viewModel.writeComment(postId, boardType)
                binding.etComment.text = null
                hideKeyboard()
                binding.nestedScrollView.post {
                    binding.nestedScrollView.fullScroll(View.FOCUS_DOWN)
                }
            }
        }
    }

    private fun initRV() {
        commentListAdapter = CommentListAdapter()

        binding.rvComment.apply {
            adapter = commentListAdapter
            layoutManager = LinearLayoutManager(context)
//                object : LinearLayoutManager(context) {
//                override fun canScrollVertically(): Boolean {
//                    return false
//                }
//            }
            isNestedScrollingEnabled = false
        }

        commentListAdapter.setOnLikeCommentListener(object :
            CommentListAdapter.OnLikeCommentListener {
            override fun onLikeComment(position: Int, comment: Comment) {
                commentPosition = position
                viewModel.likeComment(comment.id)
//                viewModel.comment.observe(binding.lifecycleOwner!!, {
//                    Log.d("tag_commentobserve", "$it and $position")
//                    commentListAdapter.notifyItemChanged(position, it)
//                })
            }
        })

//        commentListAdapter.setOnDeleteCommentListener(object :
//            CommentListAdapter.OnDeleteCommentListener {
//            override fun onDeleteComment(position: Int, comment: Comment) {
//                if (OffoffApplication.user.id == comment.value!!.author.id) {
//                    viewModel.showMyCommentDialog(comment.value!!.id)
//                } else {
//                    viewModel.showCommentDialog(comment.value!!.id)
//                }
//            }
//        })
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
            delay(2000)
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
                        //viewModel.deleteComment(commentId, postId, boardType)
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

    override fun onBackPressed() {
        if (intent.getStringExtra("update") == "true") {
            val intent = Intent(applicationContext, BoardActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
            intent.putExtra("boardType", boardType)
            intent.putExtra("boardName", boardName)
            startActivity(intent)
            finish()
        } else if (doLike == true) {

        } else
            super.onBackPressed()
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_post, menu)

        if (OffoffApplication.user.id != author) {
            Log.d(
                "tag_id",
                "id : " + OffoffApplication.user.id + "/ author: " + author.toString()
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
                val intent = Intent(applicationContext, PostWriteActivity::class.java)
                intent.putExtra("boardType", boardType)
                intent.putExtra("boardName", boardName)
                intent.putExtra("postWriteType", PostWriteType.EDIT)
                intent.putExtra("postId", postId)
                intent.putExtra("postTitle", binding.post!!.title)
                intent.putExtra("postContent", binding.post!!.content)
                startActivity(intent)
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
                if (intent.getStringExtra("update") == "true") {
                    val intent = Intent(applicationContext, BoardActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                    intent.putExtra("boardType", boardType)
                    intent.putExtra("boardName", boardName)
                    startActivity(intent)
                    finish()
                } else
                    finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

}

