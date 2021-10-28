package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import androidx.activity.viewModels
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostWriteBinding
import com.yuuuzzzin.offoff_android.utils.PostWriteType
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostWriteViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class PostWriteActivity : BaseActivity<ActivityPostWriteBinding>(R.layout.activity_post_write) {

    private val viewModel: PostWriteViewModel by viewModels()
    private lateinit var boardType: String
    private lateinit var boardName: String
    private var postWriteType: Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initViewModel()
        processIntent()
        initToolbar()
    }

    private fun processIntent() {
        boardName = intent.getStringExtra("boardName").toString()
        boardType = intent.getStringExtra("boardType").toString()
        postWriteType = intent.getIntExtra("postWriteType", PostWriteType.WRITE)

        if(postWriteType == 1) {
            val postTitle = intent.getStringExtra("postTitle").toString()
            val postContent = intent.getStringExtra("postContent").toString()
            viewModel.setPostText(postTitle, postContent)
        }
    }

    private fun initToolbar() {
        val toolbar: MaterialToolbar = binding.appbar // 상단 툴바
        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            binding.tvToolbarTitle.text = "글 쓰기"

            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_baseline_arrow_back_24)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        viewModel.alertMsg.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                showDialog(it)
            }
        })

        viewModel.successEvent.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                if(postWriteType == PostWriteType.WRITE) {
                    val intent = Intent(this@PostWriteActivity, PostActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                    intent.putExtra("id", it)
                    intent.putExtra("boardType", boardType)
                    intent.putExtra("boardName", boardName)
                    intent.putExtra("postWriteType", postWriteType)
                    startActivity(intent)
                } else {
                    val intent = Intent()
                    intent.putExtra("postWriteType", postWriteType)
                    setResult(Activity.RESULT_OK, intent)
                }

                finish()
            }
        })
    }

    fun showDialog(message : String) {
        val dialog = AlertDialog.Builder(this)
        dialog.setMessage(message)
        dialog.setIcon(android.R.drawable.ic_dialog_alert)
        dialog.setNegativeButton("확인",null)
        dialog.show()
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {

        menuInflater.inflate(R.menu.menu_post_write, menu)
        val menuItem = menu!!.getItem(0)
        val spanString = SpannableString(menu.getItem(0).title.toString())
        spanString.setSpan(ForegroundColorSpan(resources.getColor(R.color.white)), 0, spanString.length, 0)
        menuItem.title = (spanString)

        return true

    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_done -> {
                when(postWriteType){
                    PostWriteType.WRITE -> viewModel.writePost(boardType)
                    PostWriteType.EDIT -> {
                        Log.d("tag_postId", intent.getStringExtra("postId").toString())
                        viewModel.editPost(boardType, intent.getStringExtra("postId").toString())
                    }
                }
                true
            }
            android.R.id.home -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}