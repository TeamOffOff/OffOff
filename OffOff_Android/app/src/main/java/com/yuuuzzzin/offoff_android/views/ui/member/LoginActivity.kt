package com.yuuuzzzin.offoff_android.views.ui.member

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.google.android.material.textfield.TextInputLayout
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityLoginBinding
import com.yuuuzzzin.offoff_android.utils.setDefaultColor
import com.yuuuzzzin.offoff_android.utils.setErrorColor
import com.yuuuzzzin.offoff_android.utils.setVerifiedColor
import com.yuuuzzzin.offoff_android.viewmodel.LoginViewModel
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable

@AndroidEntryPoint
class LoginActivity : AppCompatActivity() {

    private var mBinding: ActivityLoginBinding? = null
    private val binding get() = mBinding!!
    private val loginViewModel: LoginViewModel by viewModels()
    private lateinit var idIcon: FontDrawable
    private lateinit var idIconFocus: FontDrawable
    private lateinit var pwIcon: FontDrawable
    private lateinit var pwIconFocus: FontDrawable
    private lateinit var errorIcon: FontDrawable

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initIcon()
        initView()
        initViewModel()
    }

    private fun initIcon() {
        // id 아이콘
        idIcon = FontDrawable(this, R.string.fa_user, true, false)
        idIcon.setTextColor(ContextCompat.getColor(this, R.color.material_on_surface_disabled))
        idIconFocus = FontDrawable(this, R.string.fa_user, true, false)
        idIconFocus.setTextColor(ContextCompat.getColor(this, R.color.green))

        // pw 아이콘
        pwIcon = FontDrawable(this, R.string.fa_lock_solid, true, false)
        pwIcon.setTextColor(ContextCompat.getColor(this, R.color.material_on_surface_disabled))
        pwIconFocus = FontDrawable(this, R.string.fa_lock_solid, true, false)
        pwIconFocus.setTextColor(ContextCompat.getColor(this, R.color.green))

        // error 아이콘
        errorIcon = FontDrawable(this, R.string.fa_exclamation_solid, true, false)
        errorIcon.setTextColor(ContextCompat.getColor(this, R.color.design_default_color_error))
    }

    private fun initView() {

        mBinding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.lifecycleOwner = this
        binding.viewModel = loginViewModel

        // 기본 에러 아이콘 제거
        binding.apply {
            tfId.setErrorIconDrawable(0)
            tfId.setTextFieldDefault()
            tfPw.setErrorIconDrawable(0)
            tfPw.setTextFieldDefault()
        }

        binding.etId.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                if (binding.etId.text!!.isEmpty())
                    binding.tfId.setTextFieldDefault()
                else
                    binding.tfId.setTextFieldFocus()
            } else
                binding.tfId.setTextFieldFocus()
        }

        binding.etPw.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                if (binding.etPw.text!!.isEmpty())
                    binding.tfPw.setTextFieldDefault()
                else
                    binding.tfPw.setTextFieldFocus()
            } else
                binding.tfPw.setTextFieldFocus()

        }

        binding.btSignup.setOnClickListener {
            val intent = Intent(this, SignupActivity::class.java)
            startActivity(intent)
        }
    }

    private fun initViewModel() {

        loginViewModel.isIdError.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.tfId.setTextFieldError(it)
            }
        })

        loginViewModel.isPwError.observe(this, { event ->
            event.getContentIfNotHandled()?.let {
                binding.tfPw.setTextFieldError(it)
            }
        })

        // 로그인 시도 후 실패하면 버튼 위 에러메시지 텍스트뷰를 visible 상태로 바꿈
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

    // TextField default 상태
    fun TextInputLayout.setTextFieldDefault() {
        this.error = null
        setDefaultColor()
        when (this.id) {
            R.id.tf_id -> startIconDrawable = idIcon
            R.id.tf_pw -> startIconDrawable = pwIcon
        }
    }

    // TextField focus 상태
    fun TextInputLayout.setTextFieldFocus() {
        setVerifiedColor()
        when (this.id) {
            R.id.tf_id -> startIconDrawable = idIconFocus
            R.id.tf_pw -> startIconDrawable = pwIconFocus
        }
    }

    // TextField error 상태
    fun TextInputLayout.setTextFieldError(errorMsg: String?) {
        error = errorMsg
        startIconDrawable = errorIcon
        setErrorColor()
    }

    // TextField error 여부
    fun TextInputLayout.isError(): Boolean {
        return this.error != null
    }

}