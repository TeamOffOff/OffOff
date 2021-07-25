package com.yuuuzzzin.offoff_android.view.ui.member

import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep2Binding
import com.yuuuzzzin.offoff_android.utils.DatePickerHelper
import com.yuuuzzzin.offoff_android.utils.base.BaseSignupFragment
import dagger.hilt.android.AndroidEntryPoint
import java.util.*

@AndroidEntryPoint
class SignupStep2Fragment : BaseSignupFragment<FragmentSignupStep2Binding>(R.layout.fragment_signup_step2) {
    lateinit var datePicker: DatePickerHelper

    override fun initView() {

        binding.viewModel = signupViewModel

        // 기본 에러 아이콘 제거
        binding.apply {
            tfName.setErrorIconDrawable(0)
            tfEmail.setErrorIconDrawable(0)
            tfBirth.setErrorIconDrawable(0)
        }

        if (signupViewModel.setStep2State())
            binding.apply {
                tfName.setTextFieldFocus()
                tfEmail.setTextFieldFocus()
                tfBirth.setTextFieldFocus()
            }
        else {
            binding.apply {
                tfName.setTextFieldDefault()
                tfEmail.setTextFieldDefault()
                tfBirth.setTextFieldDefault()
            }
        }

        datePicker = DatePickerHelper(mContext, true)
        binding.etBirth.setOnClickListener {
            showDatePickerDialog()
            if (binding.etName.text != null)
                signupViewModel.validateName()
            if (binding.etEmail.text != null)
                signupViewModel.validateEmail()
        }

        binding.etName.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                signupViewModel.validateName()
            } else {
                if(!binding.tfName.isError())
                    binding.tfName.setTextFieldFocus()
            }
        }

        binding.etEmail.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                signupViewModel.validateEmail()
            } else {
                if(!binding.tfEmail.isError())
                    binding.tfEmail.setTextFieldFocus()
            }
        }

        signupViewModel.birth.observe(viewLifecycleOwner, {
            if (!binding.etBirth.text.isNullOrEmpty()) {
                binding.tfBirth.setTextFieldVerified()
            } else {
                binding.tfBirth.setTextFieldDefault()
            }
        })

        signupViewModel.isNameVerified.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                binding.tfName.validate(it)
            }
        })

        signupViewModel.isEmailVerified.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                binding.tfEmail.validate(it)
            }
        })

        signupViewModel.isBirthVerified.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                binding.tfBirth.validate(it)
            }
        })

        signupViewModel.step2Success.observe(viewLifecycleOwner, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    findNavController().navigate(R.id.action_signupStep2Fragment_to_signupStep3Fragment)
                }
            }
        })
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        binding.appbar.apply {
            setNavigationIcon(R.drawable.ic_baseline_arrow_back_24)
            setNavigationIconTint(ContextCompat.getColor(mContext, R.color.white))
            setNavigationOnClickListener {
                findNavController().navigate(R.id.action_signupStep2Fragment_to_signupStep1Fragment)
            }
        }
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
