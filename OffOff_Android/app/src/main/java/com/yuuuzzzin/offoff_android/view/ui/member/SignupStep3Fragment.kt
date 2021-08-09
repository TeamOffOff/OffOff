package com.yuuuzzzin.offoff_android.view.ui.member

import android.app.AlertDialog
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep3Binding
import com.yuuuzzzin.offoff_android.utils.Constants
import com.yuuuzzzin.offoff_android.utils.base.BaseSignupFragment
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignupStep3Fragment :
    BaseSignupFragment<FragmentSignupStep3Binding>(R.layout.fragment_signup_step3) {

    override fun initView() {
        binding.viewModel = signupViewModel

        // 기본 에러 아이콘 제거
        binding.tfNickname.setErrorIconDrawable(0)
        binding.btProfile.setOnClickListener {
            showProfileDialog()
        }

        binding.etNickname.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (hasFocus) {
                if (!binding.tfNickname.isError()) {
                    binding.tfNickname.setTextFieldFocus()
                    binding.tfNickname.setStartIconDrawable(0)
                }
            }
        }

        signupViewModel.nickname.observe(viewLifecycleOwner, {
            if (!it.isNullOrEmpty()) {
                signupViewModel.validateNickname()
            } else {
                binding.tfNickname.setTextFieldDefault()
                binding.tfNickname.helperText = null
            }
        })

        signupViewModel.isNicknameVerified.observe(viewLifecycleOwner, {
            binding.tfNickname.helperText = it
            binding.tfNickname.setTextFieldVerified()
            binding.tfNickname.setStartIconDrawable(0)
        })

        signupViewModel.isNicknameError.observe(viewLifecycleOwner, {
            if (it.isNullOrEmpty()) {
                binding.tfNickname.setTextFieldDefault()
                binding.tfNickname.helperText = null
            } else {
                binding.tfNickname.setTextFieldError(it)
                binding.tfNickname.setStartIconDrawable(0)
            }
        })

        signupViewModel.step3Success.observe(viewLifecycleOwner, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    activity?.supportFragmentManager
                        ?.beginTransaction()
                        ?.remove(this)
                        ?.commit()
                }
            }
        })
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        binding.appbar.apply {
            setNavigationIcon(R.drawable.ic_baseline_arrow_back_24)
            setNavigationIconTint(ContextCompat.getColor(mContext, R.color.white))
            setNavigationOnClickListener {
                findNavController().navigate(R.id.action_signupStep3Fragment_to_signupStep2Fragment)
            }
        }
    }

    private fun showProfileDialog() {

        val array = arrayOf(
            Constants.PROFILE_OPTION1,
            Constants.PROFILE_OPTION2,
            Constants.PROFILE_OPTION3,
            Constants.PROFILE_OPTION4
        )
        val builder = AlertDialog.Builder(mContext)

        builder.setItems(array) { _, which ->
            val selected = array[which]

            try {
                when (which) {

                }

            } catch (e: IllegalArgumentException) {

            }
        }

        val dialog = builder.create()
        dialog.show()
    }
}