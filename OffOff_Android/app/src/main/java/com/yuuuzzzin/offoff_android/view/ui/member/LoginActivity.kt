package com.yuuuzzzin.offoff_android.view.ui.member

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.databinding.ActivityLoginBinding
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
        binding.viewModel = loginViewModel

        binding.btSignup.setOnClickListener {
            val intent = Intent(this, SignupActivity::class.java)
            startActivity(intent)
        }
    }

    private fun initViewModel() {

        loginViewModel.isIdError.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.tfId.error = it
            }
        })

        loginViewModel.isPwError.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.tfPw.error = it
            }
        })

        // 로그인 시도 후 실패하면 버튼 위 에러메시지 텍스트뷰를 visible 상태로 바꿈꿈
       loginViewModel.loginFail.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.tvAlertMsg.visibility = View.VISIBLE
                binding.tvAlertMsg.text = it
            }
        })

        loginViewModel.id.observe(this, {
            binding.tfId.error = null
            loginViewModel.alertMsg.postValue(null)
            binding.tvAlertMsg.visibility = View.GONE
        })

        loginViewModel.pw.observe(this, {
            binding.tfPw.error = null
            loginViewModel.alertMsg.postValue(null)
            binding.tvAlertMsg.visibility = View.GONE
        })

        loginViewModel.loginSuccess.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                val intent = Intent(this, MainActivity::class.java)
                intent.putExtra("id", it)
                startActivity(intent)
                finish()
            }
        })
    }
}