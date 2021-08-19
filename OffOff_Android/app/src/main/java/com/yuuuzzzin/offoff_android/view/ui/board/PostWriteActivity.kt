package com.yuuuzzzin.offoff_android.view.ui.board

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.view.Menu
import android.view.MenuItem
import androidx.activity.viewModels
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostWriteBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostWriteViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class PostWriteActivity : BaseActivity<ActivityPostWriteBinding>(R.layout.activity_post_write) {

    private val viewModel: PostWriteViewModel by viewModels()
    private lateinit var boardType: String
    private lateinit var boardName: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initViewModel()
        processIntent()
        initToolbar()
        //initView()
    }

    private fun processIntent() {
        boardName = intent.getStringExtra("boardName").toString()
        boardType = intent.getStringExtra("boardType").toString()
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
                val intent = Intent(this@PostWriteActivity, PostActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                intent.putExtra("id", it)
                intent.putExtra("boardType", boardType)
                intent.putExtra("boardName", boardName)
                intent.putExtra("update", "true")
                startActivity(intent)
                finish()
            }
        })
    }

    fun showDialog(message : String) {
        var dialog = AlertDialog.Builder(this)
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
                viewModel.writePost(boardType)
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