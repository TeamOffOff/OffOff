package com.yuuuzzzin.offoff_android.views.ui.member

import android.os.Bundle
import androidx.activity.viewModels
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityChangePwBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.ChangePwViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ChangePwActivity : BaseActivity<ActivityChangePwBinding>(R.layout.activity_change_pw) {

    private val viewModel: ChangePwViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initView()
        initViewModel()
    }

    private fun initView() {

    }

    private  fun initViewModel() {
        binding.viewModel = viewModel


    }
}