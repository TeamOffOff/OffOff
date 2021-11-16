package com.yuuuzzzin.offoff_android.views.ui.board

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.util.Log
import android.view.MenuItem
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContract
import androidx.activity.viewModels
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.LinearLayoutManager
import com.theartofdev.edmodo.cropper.CropImage
import com.theartofdev.edmodo.cropper.CropImageView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityPostWriteBinding
import com.yuuuzzzin.offoff_android.service.models.Image
import com.yuuuzzzin.offoff_android.utils.ImageUtils.bitmapToString
import com.yuuuzzzin.offoff_android.utils.PostWriteType
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.PostWriteViewModel
import com.yuuuzzzin.offoff_android.views.adapter.PostWriteImageAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class PostWriteActivity : BaseActivity<ActivityPostWriteBinding>(R.layout.activity_post_write) {

    private val viewModel: PostWriteViewModel by viewModels()
    private lateinit var imageAdapter: PostWriteImageAdapter
    private lateinit var boardType: String
    private lateinit var boardName: String
    private var postWriteType: Int = 0
    private lateinit var cropActivityResultLauncher: ActivityResultLauncher<Any?>

    private val cropResultContract by lazy {
        object : ActivityResultContract<Any?, Uri?>() {
            override fun createIntent(context: Context, input: Any?): Intent {
                return CropImage
                    .activity()
                    .setCropShape(CropImageView.CropShape.RECTANGLE)
                    .getIntent(context)
            }

            override fun parseResult(resultCode: Int, intent: Intent?): Uri? {
                return CropImage.getActivityResult(intent)?.uri
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
            val postTitle = intent.getStringExtra("postTitle").toString()
            val postContent = intent.getStringExtra("postContent").toString()
            viewModel.setPostText(postTitle, postContent)
        }
    }

    private fun initView() {

        cropActivityResultLauncher = registerForActivityResult(cropResultContract) { uri ->
            uri?.path?.let {

                val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    ImageDecoder.decodeBitmap(ImageDecoder.createSource(this.contentResolver, uri))
                } else {
                    MediaStore.Images.Media.getBitmap(this.contentResolver, uri)
                }

                // 이미지 리사이클러뷰에 이미지 아이템 추가
                imageAdapter.addItem(uri)
            }
        }

        binding.btCamera.setOnClickListener {
            cropActivityResultLauncher.launch(null)
        }
    }

    private fun initRV() {
        imageAdapter = PostWriteImageAdapter()

        val spaceDecoration = RecyclerViewUtils.VerticalSpaceItemDecoration(20) // 아이템 사이의 거리
        binding.rvImage.apply {
            adapter = imageAdapter
            layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
            addItemDecoration(spaceDecoration)
        }

        // x 버튼 눌러 이미지 리사이클러뷰의 이미지 아이템 삭제
        imageAdapter.setOnPostWriteImageClickListener(object :
            PostWriteImageAdapter.OnPostWriteImageClickListener {
            override fun onClickBtDelete(position: Int) {
                imageAdapter.removeItem(position)
            }
        })
    }

    private fun initToolbar() {
        val toolbar: Toolbar = binding.toolbar // 상단 툴바
        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            setDisplayShowTitleEnabled(false)
            setDisplayHomeAsUpEnabled(true) // 뒤로가기 버튼 생성
            setHomeAsUpIndicator(R.drawable.ic_arrow_back_white)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        binding.btDone.setOnClickListener {
            when (postWriteType) {
                PostWriteType.WRITE -> {
                    if (imageAdapter.itemCount > 0) {
                        val imageList = ArrayList<Image>()

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                            for (uri in imageAdapter.getItems()) {
                                val bitmap = ImageDecoder.decodeBitmap(
                                    ImageDecoder.createSource(
                                        this.contentResolver,
                                        uri
                                    )
                                )
                                imageList.add(Image(null, bitmapToString(bitmap)))
                            }

                            viewModel.writePost(boardType, imageList)

                        } else {
                            for (uri in imageAdapter.getItems()) {
                                val bitmap =
                                    MediaStore.Images.Media.getBitmap(this.contentResolver, uri)
                                imageList.add(Image(null, bitmapToString(bitmap)))
                            }

                            viewModel.writePost(boardType, imageList)
                        }
                    } else {
                        viewModel.writePost(boardType)
                    }
                }
                PostWriteType.EDIT -> {
                    Log.d("tag_postId", intent.getStringExtra("postId").toString())
                    viewModel.editPost(boardType, intent.getStringExtra("postId").toString())
                }
            }
        }

        viewModel.alertMsg.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                showDialog(it)
            }
        })

        viewModel.successEvent.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                if (postWriteType == PostWriteType.WRITE) {
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