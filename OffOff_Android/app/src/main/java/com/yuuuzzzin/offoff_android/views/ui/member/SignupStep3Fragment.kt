package com.yuuuzzzin.offoff_android.views.ui.member

import android.app.AlertDialog
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep3Binding
import com.yuuuzzzin.offoff_android.utils.Constants
import com.yuuuzzzin.offoff_android.utils.Constants.toast
import com.yuuuzzzin.offoff_android.utils.base.BaseSignupFragment
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignupStep3Fragment :
    BaseSignupFragment<FragmentSignupStep3Binding>(R.layout.fragment_signup_step3) {

    override fun initView() {

        // step3 -> step2 이동
        binding.btBack.setOnClickListener {
            findNavController().navigate(R.id.action_signupStep3Fragment_to_signupStep2Fragment)
        }

        binding.btCamera.setOnClickListener {
            showProfileDialog()
        }
    }

    override fun initViewModel() {
        binding.viewModel = signupViewModel

        signupViewModel.nickname.observe(viewLifecycleOwner, {
            if (!it.isNullOrBlank()) {
                signupViewModel.validateNickname()
            } else {
                binding.tvNickname.text = null
            }
        })

        signupViewModel.isNicknameVerified.observe(viewLifecycleOwner, {
            binding.tvNickname.text = it
        })

        signupViewModel.isNicknameError.observe(viewLifecycleOwner, {
            if (it.isNullOrEmpty()) {
                binding.tvNickname.text = null
            } else {
                binding.tvNickname.text = it
            }
        })

        // signup 액티비티 종료
        binding.btSignup.setOnClickListener {
            signupViewModel.signup()
            requireActivity().finish()
            requireContext().toast("가입이 완료되었습니다.")
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