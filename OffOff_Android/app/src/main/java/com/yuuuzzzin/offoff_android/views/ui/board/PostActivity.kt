package com.yuuuzzzin.offoff_android.views.ui.board

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.core.content.ContextCompat
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostBinding
import com.yuuuzzzin.offoff_android.utils.PostWriteType
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostViewModel
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable

@AndroidEntryPoint
class PostActivity : BaseActivity<ActivityPostBinding>(R.layout.activity_post) {

    private val viewModel: PostViewModel by viewModels()
    private lateinit var postId: String
    private lateinit var boardName: String
    private lateinit var boardType: String
    private lateinit var writeIcon: FontDrawable
    private lateinit var likeIcon: FontDrawable

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initViewModel()
        processIntent()
        initToolbar()
        initView()
    }

    private fun processIntent() {
        postId = intent.getStringExtra("id").toString()
        boardType = intent.getStringExtra("boardType").toString()
        boardName = intent.getStringExtra("boardName").toString()

        viewModel.getPost(postId, boardType)
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        viewModel.response.observe(binding.lifecycleOwner!!, {
            binding.post = it
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

        binding.tfId.endIconDrawable = writeIcon
    }

    override fun onBackPressed() {
        if (intent.getStringExtra("update") == "true") {
            val intent = Intent(applicationContext, BoardActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
            intent.putExtra("boardType", boardType)
            intent.putExtra("boardName", boardName)
            startActivity(intent)
            finish()
        } else
            super.onBackPressed()
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_post, menu)
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

