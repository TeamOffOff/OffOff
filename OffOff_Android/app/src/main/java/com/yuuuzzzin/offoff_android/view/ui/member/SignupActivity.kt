package com.yuuuzzzin.offoff_android.view.ui.member

import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.yuuuzzzin.offoff_android.databinding.ActivitySignupBinding
import com.yuuuzzzin.offoff_android.viewmodel.SignupViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignupActivity : AppCompatActivity() {

    private var mBinding: ActivitySignupBinding? = null
    private val binding get() = mBinding!!
    private val signupViewModel: SignupViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initView()
        initViewModel()

    }

    private fun initView() {

        mBinding = ActivitySignupBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.lifecycleOwner = this
        binding.viewModel = signupViewModel

    }

    private fun initViewModel() {

        signupViewModel.isIdError.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.tfId.error = it
            }
        })

        signupViewModel.isPwError.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.tfPw.error = it
            }
        })

        signupViewModel.isPwCheckError.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.tfCheckPw.error = it
            }
        })

        signupViewModel.id.observe(this, {
            binding.tfId.error = null
        })

        signupViewModel.pw.observe(this, {
            binding.tfPw.error = null
        })

        signupViewModel.checkPw.observe(this, {
            binding.tfCheckPw.error = null
        })

        signupViewModel.signupSuccess.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                val intent = Intent(this, LoginActivity::class.java)
                intent.putExtra("id", it)
                startActivity(intent)
                finish()
            }
        })
    }
}