package com.yuuuzzzin.offoff_android.views.ui.member

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.viewModels
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityLoginBinding
import com.yuuuzzzin.offoff_android.utils.Constants.toast
import com.yuuuzzzin.offoff_android.utils.DialogUtils.showCustomOneTextDialog
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.viewmodel.LoginViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class LoginActivity : BaseActivity<ActivityLoginBinding>(R.layout.activity_login) {

    private val viewModel: LoginViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initView()
        initViewModel()
    }

    private fun initView() {

        binding.btSignup.setOnClickListener {
            val intent = Intent(this, SignupActivity::class.java)
            startActivity(intent)
        }

        binding.btFindIdPw.setOnClickListener {
            val intent = Intent(this, FindInfoActivity::class.java)
            startActivity(intent)
        }
    }

    private fun initViewModel() {

        binding.viewModel = viewModel

        viewModel.loading.observe(binding.lifecycleOwner!!, {
            binding.layoutProgress.root.visibility = View.VISIBLE
        })

        viewModel.alertMsg.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.layoutProgress.root.visibility = View.GONE
                showCustomOneTextDialog(this, it, "확인")
            }
        })

        viewModel.loginSuccess.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
//                binding.layoutProgress.root.visibility = View.GONE

                val intent = Intent(this, MainActivity::class.java)
                startActivity(intent)
                finish()

                // 로그인 환영 메시지 출력
                applicationContext.toast("${OffoffApplication.user.subInfo.nickname}님 환영합니다.")
            }
        })
    }
}