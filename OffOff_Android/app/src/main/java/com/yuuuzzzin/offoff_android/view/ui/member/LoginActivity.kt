package com.yuuuzzzin.offoff_android.view.ui.member

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.R
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

        mBinding = DataBindingUtil.setContentView(this, R.layout.activity_login)
        binding.lifecycleOwner = this
        binding.viewModel = loginViewModel
        binding.tvAlertId.visibility = View.GONE
        binding.tvAlertPw.visibility = View.GONE

        binding.btSignup.setOnClickListener {
            val intent = Intent(this, SignupActivity::class.java)
            startActivity(intent)
        }
    }

    private fun initViewModel() {

        // alertMsg 값을 관찰하다가 값이 들어오면 error로 설정
        loginViewModel.alertId.observe(this, {
            binding.tfId.error = loginViewModel.alertId.value.toString()
        })

        // alertMsg 값을 관찰하다가 값이 들어오면 error로 설정
        loginViewModel.alertPw.observe(this, {
            binding.tfPw.error = loginViewModel.alertPw.value.toString()
        })

        loginViewModel.id.observe(this, {
            loginViewModel.alertId.postValue("")
            loginViewModel.alertMsg.postValue("")
        })

        loginViewModel.pw.observe(this, {
            loginViewModel.alertPw.postValue("")
            loginViewModel.alertMsg.postValue("")
        })

        loginViewModel.loginSuccessEvent.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                val intent = Intent(this, MainActivity::class.java)
                intent.putExtra("id", it)
                startActivity(intent)
                finish()
            }
        })
    }
}