package com.yuuuzzzin.offoff_android.views.ui.member

import android.content.Intent
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep1Binding
import com.yuuuzzzin.offoff_android.utils.base.BaseSignupFragment
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignupStep1Fragment :
    BaseSignupFragment<FragmentSignupStep1Binding>(R.layout.fragment_signup_step1) {

    override fun initView() {

        binding.btBack.setOnClickListener {
            val intent = Intent(mContext, LoginActivity::class.java)
            startActivity(intent)
        }

        // step1 -> step2 이동
        binding.btNext.setOnClickListener {
            findNavController().navigate(R.id.action_signupStep1Fragment_to_signupStep2Fragment)
        }
    }

    override fun initViewModel() {
        binding.viewModel = signupViewModel

        /* ID 파트 */
        signupViewModel.id.observe(viewLifecycleOwner, {
            signupViewModel.validateId()
        })

        signupViewModel.isIdVerified.observe(viewLifecycleOwner, {
            binding.tvId.text = it
        })

        /* PW 파트 */
        signupViewModel.pw.observe(viewLifecycleOwner, {
            signupViewModel.validatePw()
        })

        signupViewModel.isPwVerified.observe(viewLifecycleOwner, {
            binding.tvPw.text = it
        })

        binding.etPw.addTextChangedListener(object : TextWatcher {

            override fun afterTextChanged(s: Editable) {
                if (!binding.etPwConfirm.text.isNullOrEmpty() && !signupViewModel.comparePw()) {
                    signupViewModel.pwConfirm.value = ""
                    binding.tvPw.text = null
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
                if (signupViewModel.pw.value.isNullOrEmpty() || !binding.tvPw.text.isNullOrEmpty()) {
                    binding.tvPwConfirm.text = "비밀번호를 확인해주세요"
                } else {
                    signupViewModel.validatePwConfirm()
                }
            }
        }

        signupViewModel.pwConfirm.observe(viewLifecycleOwner, {
            signupViewModel.validatePwConfirm()
        })

        signupViewModel.isPwConfirmVerified.observe(viewLifecycleOwner) {
            if (!signupViewModel.pw.value.isNullOrEmpty() && binding.tvPw.text.isNullOrEmpty()) {
                binding.tvPwConfirm.text = it
            }
        }
    }
}