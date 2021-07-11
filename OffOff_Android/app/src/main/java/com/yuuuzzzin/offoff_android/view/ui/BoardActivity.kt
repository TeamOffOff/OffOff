package com.yuuuzzzin.offoff_android.view.ui

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import android.view.View
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.DividerItemDecoration.VERTICAL
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.*
import com.yuuuzzzin.offoff_android.service.RetrofitClient
import com.yuuuzzzin.offoff_android.service.model.Contents
import com.yuuuzzzin.offoff_android.service.model.Metadata
import com.yuuuzzzin.offoff_android.service.model.Post
import com.yuuuzzzin.offoff_android.view.adapter.PostListAdapter
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class BoardActivity : AppCompatActivity() {

    // ViewBinding
    private var mBinding: ActivityBoardBinding? = null
    private val binding get() = mBinding!!
    private val adapter = PostListAdapter()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mBinding = ActivityBoardBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val decoration = DividerItemDecoration(this, VERTICAL)

        binding.rvPostPreview.adapter = adapter
        binding.rvPostPreview.addItemDecoration(decoration)
        binding.rvPostPreview.layoutManager = LinearLayoutManager(this)

        initToolbar()
        getPostList()

        /* click listener 재정의 */
        adapter.setOnItemClickListener(object : PostListAdapter.OnItemClickListener {
            override fun onItemClick(view: View, post: Post) {

                val metadata = post.metadata
                val contents = post.contents

                val intent = Intent(this@BoardActivity, PostActivity::class.java)
                intent.putExtra("appBarTitle", binding.appbarBoard.title)
                intent.putExtra("metadata", metadata)
                intent.putExtra("contents", contents)
                startActivity(intent)
            }
        })
    }

    // 액티비티가 Destroy될 때
    override fun onDestroy() {
        // onDestroy 에서 binding class 인스턴스 참조를 정리해주어야 함
        mBinding = null
        super.onDestroy()
    }

    private fun initToolbar() {
        val toolbar : MaterialToolbar = binding.appbarBoard // 상단 툴바

        setSupportActionBar(toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성

        supportActionBar?.apply {
            toolbar.title = intent.getStringExtra("title")

            setDisplayHomeAsUpEnabled(true)
            setDisplayShowHomeEnabled(true)
        }

    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun getPostList() {
        RetrofitClient.postService.getPosts().enqueue(object : Callback<List<Post>> {

            override fun onFailure(call: Call<List<Post>>, t: Throwable) {
                Log.e("server_test : 실패", t.toString())
            }

            override fun onResponse(
                call: Call<List<Post>>,
                response: Response<List<Post>>
            ) {
                adapter.postList.addAll(response.body() as List<Post>)
                adapter.notifyDataSetChanged()
                Log.d("server_test : 성공", response.toString())
            }
        })
    }
}