package com.yuuuzzzin.offoff_android.views.ui.member

import android.content.Context
import android.content.Intent
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep1Binding
import com.yuuuzzzin.offoff_android.utils.base.BaseSignupFragment
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignupStep1Fragment :
    BaseSignupFragment<FragmentSignupStep1Binding>(R.layout.fragment_signup_step1) {

    private lateinit var callback: OnBackPressedCallback

    override fun onAttach(context: Context) {
        super.onAttach(context)
        callback = object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                backToLoginActivity()
            }
        }

        requireActivity().onBackPressedDispatcher.addCallback(this, callback)
    }

    override fun onDetach() {
        super.onDetach()
        callback.remove()
    }

    override fun initView() {

        binding.btBack.setOnClickListener {
            backToLoginActivity()
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
            if (it.isNullOrEmpty()) {
                binding.tvId.text = "사용 가능한 아이디입니다."
            }
        })

        /* PW 파트 */
        signupViewModel.pw.observe(viewLifecycleOwner, {
            signupViewModel.validatePw()
        })

        signupViewModel.isPwVerified.observe(viewLifecycleOwner, {
            binding.tvPw.text = it
            if (it.isNullOrEmpty()) {
                binding.tvPw.text = "사용 가능한 비밀번호입니다."
            }
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
                if (!binding.tvPw.text.isNullOrEmpty()) {
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
            if (!binding.tvPw.text.isNullOrEmpty()) {
                binding.tvPwConfirm.text = it
                if (it.isNullOrEmpty()) {
                    binding.tvPwConfirm.text = "비밀번호가 일치합니다."
                }
            }
        }
    }

    private fun backToLoginActivity() {
        val intent = Intent(mContext, LoginActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        startActivity(intent)
    }
}