package com.yuuuzzzin.offoff_android.view.ui.member

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep1Binding
import com.yuuuzzzin.offoff_android.utils.base.BaseSignupFragment
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignupStep1Fragment :
    BaseSignupFragment<FragmentSignupStep1Binding>(R.layout.fragment_signup_step1) {

    override fun initView() {
        binding.viewModel = signupViewModel

        // 기본 에러 아이콘 제거
        binding.apply {
            tfId.setErrorIconDrawable(0)
            tfPw.setErrorIconDrawable(0)
            tfPwConfirm.setErrorIconDrawable(0)
        }

        if (signupViewModel.setStep1State())
            binding.apply {
                tfId.setTextFieldFocus()
                tfPw.setTextFieldFocus()
                tfPwConfirm.setTextFieldFocus()
            }
        else {
            binding.apply {
                tfId.setTextFieldDefault()
                tfPw.setTextFieldDefault()
                tfPwConfirm.setTextFieldDefault()
            }
        }

        /* ID 파트 */
        binding.etId.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                signupViewModel.validateId()
            } else {
                if (!binding.tfId.isError())
                    binding.tfId.setTextFieldFocus()
            }
        }

        signupViewModel.id.observe(viewLifecycleOwner, {
            signupViewModel.validateId()
        })

        signupViewModel.isIdVerified.observe(viewLifecycleOwner, {
            binding.tfId.validate(it)
        })

        /* PW 파트 */
        binding.etPw.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                signupViewModel.validatePw()
            } else {
                if (!binding.tfPw.isError()) {
                    binding.tfPw.setTextFieldFocus()
                }
            }
        }

        signupViewModel.pw.observe(viewLifecycleOwner, {
            signupViewModel.validatePw()
        })

        signupViewModel.isPwVerified.observe(viewLifecycleOwner, {
            binding.tfPw.validate(it)
        })

        binding.etPw.addTextChangedListener(object : TextWatcher {

            override fun afterTextChanged(s: Editable) {
                if (!binding.etPwConfirm.text.isNullOrEmpty() && !signupViewModel.comparePw()) {
                    signupViewModel.pwConfirm.value = ""
                    if (!binding.tfPwConfirm.isError())
                        binding.tfPwConfirm.setTextFieldDefault()
                }
            }

            override fun beforeTextChanged(
                s: CharSequence, start: Int,
                count: Int, after: Int
            ) {
            }

            override fun onTextChanged(
                s: CharSequence, start: Int,
                before: Int, count: Int
            ) {
            }
        })

        /* PW 확인 파트 */
        binding.etPwConfirm.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (hasFocus) {
                if (signupViewModel.pw.value.isNullOrEmpty() || binding.tfPw.isError()) {
                    binding.tfPwConfirm.setTextFieldError("비밀번호를 확인해주세요")
                } else if (!binding.tfPwConfirm.isError())
                    binding.tfPwConfirm.setTextFieldFocus()
            }
        }

        signupViewModel.pwConfirm.observe(viewLifecycleOwner, {
            signupViewModel.validatePwConfirm()

        })

        signupViewModel.isPwConfirmVerified.observe(viewLifecycleOwner) {
            binding.tfPwConfirm.validate(it)
        }

        // step1 -> step2 이동
        binding.btNext.setOnClickListener {
            findNavController().navigate(R.id.action_signupStep1Fragment_to_signupStep2Fragment)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        binding.appbar.apply {
            setNavigationIcon(R.drawable.ic_baseline_arrow_back_24)
            setNavigationIconTint(ContextCompat.getColor(mContext, R.color.white))
            setNavigationOnClickListener {
                val intent = Intent(mContext, LoginActivity::class.java)
                startActivity(intent)
            }
        }
    }
}