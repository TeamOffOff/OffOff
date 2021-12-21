package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.LinearLayoutManager
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostWriteBinding
import com.yuuuzzzin.offoff_android.service.models.Image
import com.yuuuzzzin.offoff_android.service.models.Post
import com.yuuuzzzin.offoff_android.utils.DialogUtils
import com.yuuuzzzin.offoff_android.utils.ImageUtils.bitmapToString
import com.yuuuzzzin.offoff_android.utils.ImageUtils.stringToBitmap
import com.yuuuzzzin.offoff_android.utils.ImageUtils.uriToBitmap
import com.yuuuzzzin.offoff_android.utils.KeyboardUtils.hideKeyboard
import com.yuuuzzzin.offoff_android.utils.PostWriteType
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostWriteViewModel
import com.yuuuzzzin.offoff_android.views.adapter.PostWriteImageAdapter
import com.yuuuzzzin.offoff_android.views.ui.LoadingDialog
import dagger.hilt.android.AndroidEntryPoint
import java.io.IOException

@AndroidEntryPoint
class PostWriteActivity : BaseActivity<ActivityPostWriteBinding>(R.layout.activity_post_write) {

    private val viewModel: PostWriteViewModel by viewModels()
    private lateinit var imageAdapter: PostWriteImageAdapter
    private lateinit var loadingDialog: LoadingDialog
    private lateinit var boardType: String
    private lateinit var boardName: String
    private var postId: String? = null
    private var postWriteType: Int = 0
    private var imageList: List<Image>? = null

    private val requestActivity =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            if (it.resultCode == Activity.RESULT_OK) {
                try {

                    // 이미지 다중 선택시
                    if (it.data?.clipData != null) {

                        val count = it.data!!.clipData!!.itemCount

                        if (count > 10 || (imageAdapter.itemCount + count) > 10) {
                            DialogUtils.showCustomOneTextDialog(
                                this,
                                "선택 가능 사진 최대 개수는 10장입니다.",
                                "확인"
                            )
                        } else {
                            val list = mutableListOf<Bitmap>()
                            for (i in 0 until count) {
                                list.add(uriToBitmap(it.data!!.clipData!!.getItemAt(i).uri, this))
                            }

                            if (binding.rvImage.adapter!!.itemCount == 0) {
                                binding.rvImage.visibility = View.VISIBLE
                            }

                            imageAdapter.addItems(list)
                        }
                    }

                    // 이미지 단일 선택시
                    else if (it.data?.data != null) {

                        if (binding.rvImage.adapter!!.itemCount == 0) {
                            binding.rvImage.visibility = View.VISIBLE
                        }

                        imageAdapter.addItem(uriToBitmap(it.data?.data!!, this))
                    }
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initViewModel()
        initView()
        initRV()
        processIntent()
        initToolbar()
    }

    private fun processIntent() {
        boardName = intent.getStringExtra("boardName").toString()
        boardType = intent.getStringExtra("boardType").toString()
        postWriteType = intent.getIntExtra("postWriteType", PostWriteType.WRITE)

        if (postWriteType == 1) {
            val post: Post = intent.getSerializableExtra("post") as Post
            viewModel.setPostText(post.title, post.content)
            if (!post.image.isNullOrEmpty()) {

                imageList = post.image
                Log.d("tag_이미지", post.image.toString())

                val list = mutableListOf<Bitmap>()
                for (i in post.image)
                    list.add(stringToBitmap(i.body!!))

                imageAdapter.addItems(list)
                binding.rvImage.visibility = View.VISIBLE
            }
            postId = post.id
        }
    }

    private fun initView() {

        loadingDialog = LoadingDialog(this@PostWriteActivity)

        binding.btCamera.setOnClickListener {

            if (imageAdapter.itemCount >= 10) {
                DialogUtils.showCustomOneTextDialog(this, "선택 가능 사진 최대 개수는 10장입니다.", "확인")
            } else {
                val intent = Intent()
                intent.type = "image/*"
                intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
                intent.action = Intent.ACTION_GET_CONTENT
                requestActivity.launch(intent)
            }
        }
    }

    private fun initRV() {
        imageAdapter = PostWriteImageAdapter()

        val spaceDecoration = RecyclerViewUtils.VerticalSpaceItemDecoration(20) // 아이템 사이의 거리
        binding.rvImage.apply {
            adapter = imageAdapter
            layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
            addItemDecoration(spaceDecoration)
            hasFixedSize()
        }

        // x 버튼 눌러 이미지 리사이클러뷰의 이미지 아이템 삭제
        imageAdapter.setOnPostWriteImageClickListener(object :
            PostWriteImageAdapter.OnPostWriteImageClickListener {
            override fun onClickBtDelete(position: Int) {
                imageAdapter.removeItem(position)

                if (binding.rvImage.adapter!!.itemCount == 0) {
                    binding.rvImage.visibility = View.GONE
                }
            }
        })
    }

    private fun initToolbar() {
        val toolbar: Toolbar = binding.toolbar // 상단 툴바
        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white_resized)
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        binding.btDone.setOnClickListener {
            hideKeyboard()

            when (postWriteType) {
                PostWriteType.WRITE -> {
                    if (imageAdapter.itemCount > 0) {
                        val imageList = ArrayList<Image>()
                        for (bitmap in imageAdapter.getItems()) {
                            imageList.add(Image(null, bitmapToString(bitmap)))
                        }
                        viewModel.writePost(boardType, imageList)

                    } else {
                        viewModel.writePost(boardType)
                    }
                }
                PostWriteType.EDIT -> {
                    viewModel.editPost(boardType, postId!!, imageList)
                }
            }
        }

        viewModel.alertMsg.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                showDialog(it)
            }
        })

        viewModel.loading.observe(binding.lifecycleOwner!!, {
            loadingDialog.show()
        })

        viewModel.successEvent.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                if (postWriteType == PostWriteType.WRITE) {
                    val intent = Intent(this@PostWriteActivity, PostActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                    intent.putExtra("id", it)
                    intent.putExtra("boardType", boardType)
                    intent.putExtra("postWriteType", postWriteType)
                    startActivity(intent)
                    loadingDialog.dismiss()
                } else {
                    val intent = Intent()
                    intent.putExtra("postWriteType", postWriteType)
                    setResult(Activity.RESULT_OK, intent)
                    loadingDialog.dismiss()
                }

                finish()
            }
        })
    }

    fun showDialog(message: String) {
        val dialog = AlertDialog.Builder(this)
        dialog.setMessage(message)
        dialog.setIcon(android.R.drawable.ic_dialog_alert)
        dialog.setNegativeButton("확인", null)
        dialog.show()
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
}