package com.yuuuzzzin.offoff_android.views.ui.member

import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep2Binding
import com.yuuuzzzin.offoff_android.utils.DatePickerHelper
import com.yuuuzzzin.offoff_android.utils.base.BaseSignupFragment
import dagger.hilt.android.AndroidEntryPoint
import java.util.*

@AndroidEntryPoint
class SignupStep2Fragment :
    BaseSignupFragment<FragmentSignupStep2Binding>(R.layout.fragment_signup_step2) {
    lateinit var datePicker: DatePickerHelper

    override fun initView() {

        // step2 -> step1 이동
        binding.btBack.setOnClickListener {
            findNavController().navigate(R.id.action_signupStep2Fragment_to_signupStep1Fragment)
        }

        // step2 -> step3 이동
        binding.btNext.setOnClickListener {
            findNavController().navigate(R.id.action_signupStep2Fragment_to_signupStep3Fragment)
        }
    }

    override fun initViewModel() {
        binding.viewModel = signupViewModel

        datePicker = DatePickerHelper(mContext, true)
        binding.etBirth.setOnClickListener {
            showDatePickerDialog()
            if (binding.etName.text != null)
                signupViewModel.validateName()
            if (binding.etEmail.text != null)
                signupViewModel.validateEmail()
        }

        /* 이름 파트 */
        signupViewModel.name.observe(viewLifecycleOwner, {
            signupViewModel.validateName()
        })

        signupViewModel.isNameVerified.observe(viewLifecycleOwner, {
            binding.tvName.text = it
        })

        /* 이메일 파트 */
        signupViewModel.email.observe(viewLifecycleOwner, {
            signupViewModel.validateEmail()
        })

        signupViewModel.isEmailVerified.observe(viewLifecycleOwner, {
            binding.tvEmail.text = it
            if (it.isNullOrEmpty()) {
                binding.tvEmail.text = "사용 가능한 이메일 주소입니다."
            }
        })

        /* 생년월일 파트 */
        signupViewModel.birth.observe(viewLifecycleOwner, {
            signupViewModel.validateBirth()
        })

        signupViewModel.isBirthVerified.observe(viewLifecycleOwner, {
            binding.tvBirth.text = it
        })
    }

    private fun showDatePickerDialog() {
        val cal = Calendar.getInstance()
        val y = cal.get(Calendar.YEAR)
        val m = cal.get(Calendar.MONTH)
        val d = cal.get(Calendar.DAY_OF_MONTH)

        val minFormat = datePicker.convertDateToLong("1940.01.01")
        datePicker.setMinDate(minFormat)
        datePicker.setMaxDate(System.currentTimeMillis() - 1000)

        datePicker.showDialog(1, 0, 2002, object : DatePickerHelper.Callback {
            override fun onDateSelected(dayofMonth: Int, month: Int, year: Int) {
                val dayStr = if (dayofMonth < 10) "0${dayofMonth}" else "${dayofMonth}"
                val mon = month + 1
                val monthStr = if (mon < 10) "0${mon}" else "${mon}"
                binding.etBirth.setText("${year}년 ${monthStr}월 ${dayStr}일")
            }
        })
    }
}
