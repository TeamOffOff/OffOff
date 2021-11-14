package com.yuuuzzzin.offoff_android.views.ui.member

import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.databinding.ActivityLoginBinding
import com.yuuuzzzin.offoff_android.utils.Constants.toast
import com.yuuuzzzin.offoff_android.utils.DialogUtils.showCustomOneTextDialog
import com.yuuuzzzin.offoff_android.viewmodel.LoginViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class LoginActivity : AppCompatActivity() {

    private var mBinding: ActivityLoginBinding? = null
    private val binding get() = mBinding!!
    private val loginViewModel: LoginViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initView()
        initViewModel()
    }

    private fun initView() {

        mBinding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.lifecycleOwner = this

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

        binding.viewModel = loginViewModel

        loginViewModel.alertMsg.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                showCustomOneTextDialog(this, it, "확인")
            }
        })

        loginViewModel.loginSuccess.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                val intent = Intent(this, MainActivity::class.java)
                intent.putExtra("id", it)
                startActivity(intent)
                finish()

                // 로그인 환영 메시지 출력
                applicationContext.toast("${OffoffApplication.user.subInfo.nickname}님 환영합니다.")
            }
        })
    }
}