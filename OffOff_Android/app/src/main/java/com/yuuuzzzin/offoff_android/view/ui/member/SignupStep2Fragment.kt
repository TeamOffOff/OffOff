package com.yuuuzzzin.offoff_android.view.ui.member

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep2Binding
import com.yuuuzzzin.offoff_android.utils.DatePickerHelper
import com.yuuuzzzin.offoff_android.utils.setDefaultColor
import com.yuuuzzzin.offoff_android.utils.setValidColor
import com.yuuuzzzin.offoff_android.viewmodel.SignupViewModel
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable
import java.util.*

@AndroidEntryPoint
class SignupStep2Fragment : Fragment() {

    private var mBinding: FragmentSignupStep2Binding? = null
    private val binding get() = mBinding!!
    private val signupViewModel: SignupViewModel by activityViewModels()
    private lateinit var mContext: Context
    lateinit var datePicker: DatePickerHelper
    private lateinit var name_fontDrawable: FontDrawable
    private lateinit var name_fontDrawable_focus: FontDrawable
    private lateinit var email_fontDrawable: FontDrawable
    private lateinit var email_fontDrawable_focus: FontDrawable
    private lateinit var birth_fontDrawable: FontDrawable
    private lateinit var birth_fontDrawable_focus: FontDrawable
    private lateinit var error_fontDrawable: FontDrawable
    private lateinit var check_fontDrawable: FontDrawable

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is SignupActivity)
            mContext = context
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        mBinding = FragmentSignupStep2Binding.inflate(inflater, container, false)
        binding.viewModel = signupViewModel
        binding.lifecycleOwner = viewLifecycleOwner

        initIcon()
        binding.tfName.startIconDrawable = name_fontDrawable
        binding.tfEmail.startIconDrawable = email_fontDrawable
        binding.tfBirth.startIconDrawable = birth_fontDrawable

        if (signupViewModel.setStep2State())
            setTextFieldValid()
        else {
            binding.tfName.startIconDrawable = name_fontDrawable
            binding.tfEmail.startIconDrawable = email_fontDrawable
            binding.tfBirth.startIconDrawable = birth_fontDrawable
        }

        datePicker = DatePickerHelper(mContext, true)
        binding.etBirth.setOnClickListener {
            showDatePickerDialog()
            signupViewModel.validateName()
            signupViewModel.validateEmail()
        }

        binding.etName.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                binding.tfName.startIconDrawable = name_fontDrawable
                if (signupViewModel.validateName()) {
                    binding.tfName.startIconDrawable = check_fontDrawable
                    binding.tfName.setValidColor()
                }
            } else if (hasFocus) {
                if (binding.tfName.error != null) {
                    binding.tfName.startIconDrawable = error_fontDrawable
                } else {
                    binding.tfName.startIconDrawable = name_fontDrawable_focus
                    binding.tfName.setValidColor()
                }
            }
        }

        binding.etEmail.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                binding.tfEmail.startIconDrawable = email_fontDrawable
                if (signupViewModel.validateEmail()) {
                    binding.tfEmail.startIconDrawable = check_fontDrawable
                    binding.tfEmail.setValidColor()
                }
            } else if (hasFocus) {
                if (binding.tfEmail.error != null) {
                    binding.tfEmail.startIconDrawable = error_fontDrawable
                } else {
                    binding.tfEmail.startIconDrawable = email_fontDrawable_focus
                    binding.tfEmail.setValidColor()
                }
            }
        }

        signupViewModel.birth.observe(viewLifecycleOwner, {
            if (signupViewModel.validateBirth()) {
                binding.tfBirth.startIconDrawable = check_fontDrawable
                binding.tfBirth.setValidColor()
            } else {
                binding.tfBirth.startIconDrawable = birth_fontDrawable
                binding.tfBirth.setDefaultColor()
            }
        })

        signupViewModel.isNameError.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                Log.d(
                    "focusloose_tag",
                    signupViewModel.id.toString() + " / " + binding.etName.text.toString()
                )
                binding.tfName.error = it
                if (it != "") {
                    binding.tfName.startIconDrawable = error_fontDrawable
                    binding.tfName.setDefaultColor()
                } else {
                    binding.tfName.startIconDrawable = check_fontDrawable
                    binding.tfName.setValidColor()
                }
            }
        })

        signupViewModel.isEmailError.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                binding.tfEmail.error = it
                if (it != "") {
                    binding.tfEmail.startIconDrawable = error_fontDrawable
                    binding.tfEmail.setDefaultColor()
                } else {
                    binding.tfEmail.startIconDrawable = check_fontDrawable
                    binding.tfEmail.setValidColor()
                }
            }
        })

        signupViewModel.isBirthError.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                binding.tfBirth.error = it
                if (it != "") {
                    binding.tfBirth.startIconDrawable = error_fontDrawable
                    binding.tfBirth.setDefaultColor()
                } else {
                    binding.tfBirth.startIconDrawable = check_fontDrawable
                    binding.tfBirth.setValidColor()
                }
            }
        })

        signupViewModel.step2Success.observe(viewLifecycleOwner, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    binding.tfName.setValidColor()
                    binding.tfEmail.setValidColor()
                    binding.tfBirth.setValidColor()
                    findNavController().navigate(R.id.action_signupStep2Fragment_to_signupStep3Fragment)
                }
            }
        })

        return binding.root
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

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
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

    private fun initIcon() {
        // name 아이콘
        name_fontDrawable = FontDrawable(mContext, R.string.fa_user, true, false)
        name_fontDrawable.setTextColor(
            ContextCompat.getColor(
                mContext,
                R.color.material_on_background_disabled
            )
        )
        name_fontDrawable_focus = FontDrawable(mContext, R.string.fa_user, true, false)
        name_fontDrawable_focus.setTextColor(ContextCompat.getColor(mContext, R.color.green))

        // email 아이콘
        email_fontDrawable = FontDrawable(mContext, R.string.fa_at_solid, true, false)
        email_fontDrawable.setTextColor(
            ContextCompat.getColor(
                mContext,
                R.color.material_on_background_disabled
            )
        )
        email_fontDrawable_focus = FontDrawable(mContext, R.string.fa_at_solid, true, false)
        email_fontDrawable_focus.setTextColor(ContextCompat.getColor(mContext, R.color.green))

        // 생년월일 아이콘
        birth_fontDrawable = FontDrawable(mContext, R.string.fa_birthday_cake_solid, true, false)
        email_fontDrawable.setTextColor(
            ContextCompat.getColor(
                mContext,
                R.color.material_on_background_disabled
            )
        )
        birth_fontDrawable_focus =
            FontDrawable(mContext, R.string.fa_birthday_cake_solid, true, false)
        email_fontDrawable_focus.setTextColor(ContextCompat.getColor(mContext, R.color.green))

        // 에러
        error_fontDrawable = FontDrawable(mContext, R.string.fa_exclamation_solid, true, false)
        error_fontDrawable.setTextColor(
            ContextCompat.getColor(
                mContext,
                R.color.design_default_color_error
            )
        )

        // 확인
        check_fontDrawable = FontDrawable(mContext, R.string.fa_check_circle_solid, true, false)
        check_fontDrawable.setTextColor(ContextCompat.getColor(mContext, R.color.green))
    }

    private fun setTextFieldValid() {
        binding.apply {
            tfName.setValidColor()
            tfName.startIconDrawable = check_fontDrawable
            tfEmail.setValidColor()
            tfEmail.startIconDrawable = check_fontDrawable
            tfBirth.setValidColor()
            tfBirth.startIconDrawable = check_fontDrawable
        }
    }
}

//        binding.etBirth.setOnClickListener {
////            datepickerdialog에 표시할 달력
//            val datepicker = Calendar.getInstance()
//            val year = datepicker.get(Calendar.YEAR)
//            val month = datepicker.get(Calendar.MONTH)
//            val day = datepicker.get(Calenddar.DAY_OF_MONTH)
//
//            val dpd = DatePickerDialog(
//                requireContext(),
//                R.style.MyDatePicker,
//                { _, year, monthOfYear, dayOfMonth ->
////                  월이 0부터 시작하여 1을 더해주어야함
//                    val month = monthOfYear + 1
////                   선택한 날짜의 요일을 구하기 위한 calendar
//                    val calendar = Calendar.getInstance()
////                    선택한 날짜 세팅
//                    calendar.set(year, monthOfYear, dayOfMonth)
//                    val date = calendar.time
//                    val simpledateformat = SimpleDateFormat("EEEE", Locale.getDefault())
//
//                    binding.etBirth.setText("$year.$month.$dayOfMonth")
//
//                },
//                year,
//                month,
//                day
//            )
////           최소 날짜를 현재 시각 이후로
//            dpd.datePicker.maxDate = System.currentTimeMillis() - 1000;
//            dpd.show()
//        }