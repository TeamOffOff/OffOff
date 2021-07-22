package com.yuuuzzzin.offoff_android.view.ui.member

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep1Binding
import com.yuuuzzzin.offoff_android.utils.setDefaultColor
import com.yuuuzzzin.offoff_android.utils.setValidColor
import com.yuuuzzzin.offoff_android.viewmodel.SignupViewModel
import dagger.hilt.android.AndroidEntryPoint
import info.androidhive.fontawesome.FontDrawable

@AndroidEntryPoint
class SignupStep1Fragment : Fragment() {

    private var mBinding: FragmentSignupStep1Binding? = null
    private val binding get() = mBinding!!
    private val signupViewModel: SignupViewModel by activityViewModels()
    private lateinit var mContext: Context
    private lateinit var id_fontDrawable: FontDrawable
    private lateinit var id_fontDrawable_focus: FontDrawable
    private lateinit var pw_fontDrawable: FontDrawable
    private lateinit var pw_fontDrawable_focus: FontDrawable
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
        mBinding = FragmentSignupStep1Binding.inflate(inflater, container, false)
        binding.viewModel = signupViewModel
        binding.lifecycleOwner = viewLifecycleOwner

        initIcon()
        binding.tfId.setErrorIconDrawable(0)
        binding.tfPw.setErrorIconDrawable(0)
        binding.tfPwConfirm.setErrorIconDrawable(0)

        if(signupViewModel.setStep1State())
            setTextFieldValid()
        else {
                binding.tfId.startIconDrawable = id_fontDrawable
                binding.tfPw.startIconDrawable = pw_fontDrawable
                binding.tfPwConfirm.startIconDrawable = pw_fontDrawable
        }

        var isPwConfirmValid = false

        binding.etId.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                binding.tfId.startIconDrawable = id_fontDrawable
                if(signupViewModel.validateId()) {
                    binding.tfId.startIconDrawable = check_fontDrawable
                    binding.tfId.setValidColor()
                }
            }
            else if(hasFocus){
                if(binding.tfId.error != null) {
                    binding.tfId.startIconDrawable = error_fontDrawable
                }
                else {
                    binding.tfId.startIconDrawable = id_fontDrawable_focus
                    binding.tfId.setValidColor()
                }
            }
        }

        binding.etPw.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                
                binding.tfPw.startIconDrawable = pw_fontDrawable
                if (signupViewModel.validatePw()) {
                    binding.tfPw.startIconDrawable = check_fontDrawable
                    binding.tfPw.setValidColor()
                }
            } else if (hasFocus) {
                if (binding.tfPw.error != null) {
                    binding.tfPw.startIconDrawable = error_fontDrawable
                } else {
                    binding.tfPw.startIconDrawable = pw_fontDrawable_focus
                }
                binding.etPw.addTextChangedListener(object : TextWatcher {

                    override fun afterTextChanged(s: Editable) {

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
                        if(signupViewModel.getUserPw() != binding.etPw.text.toString()) {
                            signupViewModel.pwConfirm.postValue("")
                            if(binding.tfPwConfirm.error == null) {
                                binding.tfPwConfirm.startIconDrawable = pw_fontDrawable
                                binding.tfPwConfirm.setDefaultColor()
                            }
                        }
                    }
                })
            }
        }

        binding.etPwConfirm.setOnFocusChangeListener { _: View?, hasFocus: Boolean ->
            if (!hasFocus) {
                when {
                    binding.tfPwConfirm.error != null -> {
                        binding.tfPwConfirm.startIconDrawable = error_fontDrawable
                    }
                    isPwConfirmValid -> {
                        binding.tfPwConfirm.startIconDrawable = check_fontDrawable
                        binding.tfPwConfirm.setValidColor()
                    }
                    else -> {
                        binding.tfPwConfirm.startIconDrawable = pw_fontDrawable
                        binding.tfPwConfirm.setDefaultColor()
                    }
                }
            } else if (hasFocus) {
                if(binding.tfPwConfirm.error != null) {
                    binding.tfPwConfirm.startIconDrawable = error_fontDrawable
                }
                else {
                    binding.tfPwConfirm.startIconDrawable = pw_fontDrawable_focus
                    binding.tfPwConfirm.setValidColor()
                }
                signupViewModel.pwConfirm.observe(viewLifecycleOwner, {
                    isPwConfirmValid = false
                    if((it?.length)!! >= (binding.etPw.text?.length)!!) {
                        if (signupViewModel.validatePwConfirm()) {
                            isPwConfirmValid = true
                            binding.tfPwConfirm.startIconDrawable = check_fontDrawable
                            binding.tfPwConfirm.setValidColor()
                        }
                        else
                            binding.tfPwConfirm.startIconDrawable = error_fontDrawable
                    }
                })
            }
        }

        signupViewModel.isIdError.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                binding.tfId.error = it
                if(it != "") {
                    binding.tfId.startIconDrawable = error_fontDrawable
                } else {
                    binding.tfId.startIconDrawable = check_fontDrawable
                }
            }
        })

        signupViewModel.isPwError.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                binding.tfPw.error = it
                if(it != "") {
                    binding.tfPw.startIconDrawable = error_fontDrawable
                } else {
                    binding.tfPw.startIconDrawable = check_fontDrawable
                }
            }
        })

        signupViewModel.isPwConfirmError.observe(viewLifecycleOwner, { event ->
            event?.getContentIfNotHandled()?.let {
                binding.tfPwConfirm.error = it
                if(it != "") {
                    binding.tfPwConfirm.startIconDrawable = error_fontDrawable
                } else {
                    binding.tfPwConfirm.startIconDrawable = check_fontDrawable
                }
            }
        })

        signupViewModel.step1Success.observe(viewLifecycleOwner, { event ->
            event.getContentIfNotHandled()?.let {
                if(it) {
                    binding.tfId.setValidColor()
                    binding.tfPw.setValidColor()
                    binding.tfPwConfirm.setValidColor()
                    findNavController().navigate(R.id.action_signupStep1Fragment_to_signupStep2Fragment)
                }
            }
        })

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        binding.appbar.apply {
            setNavigationIcon(R.drawable.ic_baseline_arrow_back_24)
            setNavigationIconTint(ContextCompat.getColor(mContext, R.color.white))
            setNavigationOnClickListener{
                val intent = Intent(mContext, LoginActivity::class.java)
                startActivity(intent)            }
        }
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

    private fun initIcon() {
        // id 아이콘
        id_fontDrawable = FontDrawable(mContext, R.string.fa_user, true, false)
        id_fontDrawable.setTextColor(ContextCompat.getColor(mContext, R.color.material_on_background_disabled))
        id_fontDrawable_focus = FontDrawable(mContext, R.string.fa_user, true, false)
        id_fontDrawable_focus.setTextColor(ContextCompat.getColor(mContext, R.color.green))

        // pw 아이콘
        pw_fontDrawable = FontDrawable(mContext, R.string.fa_lock_solid, true, false)
        pw_fontDrawable.setTextColor(ContextCompat.getColor(mContext, R.color.material_on_background_disabled))
        pw_fontDrawable_focus = FontDrawable(mContext, R.string.fa_lock_solid, true, false)
        pw_fontDrawable_focus.setTextColor(ContextCompat.getColor(mContext, R.color.green))

        // 에러
        error_fontDrawable = FontDrawable(mContext, R.string.fa_exclamation_solid, true, false)
        error_fontDrawable.setTextColor(ContextCompat.getColor(mContext, R.color.design_default_color_error))

        // 확인
        check_fontDrawable = FontDrawable(mContext, R.string.fa_check_circle_solid, true, false)
        check_fontDrawable.setTextColor(ContextCompat.getColor(mContext, R.color.green))

    }

    private fun setTextFieldValid() {
        binding.apply {
            tfId.setValidColor()
            tfId.startIconDrawable = check_fontDrawable
            tfPw.setValidColor()
            tfPw.startIconDrawable = check_fontDrawable
            tfPwConfirm.setValidColor()
            tfPwConfirm.startIconDrawable = check_fontDrawable
        }
    }
}