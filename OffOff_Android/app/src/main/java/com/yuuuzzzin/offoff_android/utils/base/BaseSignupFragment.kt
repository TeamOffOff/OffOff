package com.yuuuzzzin.offoff_android.utils.base

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.annotation.LayoutRes
import androidx.databinding.DataBindingUtil
import androidx.databinding.ViewDataBinding
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.yuuuzzzin.offoff_android.viewmodel.SignupViewModel
import com.yuuuzzzin.offoff_android.views.ui.member.SignupActivity

abstract class BaseSignupFragment<T : ViewDataBinding>(
    @LayoutRes private val layoutRes: Int
) : Fragment() {

    private var mBinding: T? = null
    protected val binding get() = mBinding!!
    protected val signupViewModel: SignupViewModel by activityViewModels()
    lateinit var mContext: Context
//    lateinit var idIcon: FontDrawable
//    lateinit var idIconFocus: FontDrawable
//    lateinit var pwIcon: FontDrawable
//    lateinit var pwIconFocus: FontDrawable
//    lateinit var nameIcon: FontDrawable
//    lateinit var nameIconFocus: FontDrawable
//    lateinit var emailIcon: FontDrawable
//    lateinit var emailIconFocus: FontDrawable
//    lateinit var birthIcon: FontDrawable
//    lateinit var birthIconFocus: FontDrawable
//    lateinit var verifiedIcon: FontDrawable
//    lateinit var errorIcon: FontDrawable

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if(context is SignupActivity) {
            this.mContext = context
        } else {
            throw RuntimeException("$context error")
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = DataBindingUtil.inflate(inflater, layoutRes, container, false)
        binding.lifecycleOwner = viewLifecycleOwner
        //initIcon()
        initView()

        return binding.root
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

    open fun initView() {}

//    fun initIcon() {
//        // id 아이콘
//        idIcon = FontDrawable(mContext, R.string.fa_user, true, false)
//        idIcon.setTextColor(ContextCompat.getColor(mContext, R.color.material_on_surface_disabled))
//        idIconFocus = FontDrawable(mContext, R.string.fa_user, true, false)
//        idIconFocus.setTextColor(ContextCompat.getColor(mContext, R.color.green))
//
//        // pw 아이콘
//        pwIcon = FontDrawable(mContext, R.string.fa_lock_solid, true, false)
//        pwIcon.setTextColor(ContextCompat.getColor(mContext, R.color.material_on_surface_disabled))
//        pwIconFocus = FontDrawable(mContext, R.string.fa_lock_solid, true, false)
//        pwIconFocus.setTextColor(ContextCompat.getColor(mContext, R.color.green))
//
//        // name 아이콘
//        nameIcon = FontDrawable(mContext, R.string.fa_user, true, false)
//        nameIcon.setTextColor(ContextCompat.getColor(mContext, R.color.material_on_surface_disabled))
//        nameIconFocus = FontDrawable(mContext, R.string.fa_user, true, false)
//        nameIconFocus.setTextColor(ContextCompat.getColor(mContext, R.color.green))
//
//        // email 아이콘
//        emailIcon = FontDrawable(mContext, R.string.fa_at_solid, true, false)
//        emailIcon.setTextColor(ContextCompat.getColor(mContext, R.color.material_on_surface_disabled))
//        emailIconFocus = FontDrawable(mContext, R.string.fa_at_solid, true, false)
//        emailIconFocus.setTextColor(ContextCompat.getColor(mContext, R.color.green))
//
//        // birth 아이콘
//        birthIcon = FontDrawable(mContext, R.string.fa_birthday_cake_solid, true, false)
//        birthIcon.setTextColor(ContextCompat.getColor(mContext, R.color.material_on_surface_disabled))
//        birthIconFocus = FontDrawable(mContext, R.string.fa_birthday_cake_solid, true, false)
//        birthIconFocus.setTextColor(ContextCompat.getColor(mContext, R.color.green))
//
//        // verified 아이콘
//        verifiedIcon = FontDrawable(mContext, R.string.fa_check_circle_solid, true, false)
//        verifiedIcon.setTextColor(ContextCompat.getColor(mContext, R.color.green))
//
//        // error 아이콘
//        errorIcon = FontDrawable(mContext, R.string.fa_exclamation_solid, true, false)
//        errorIcon.setTextColor(ContextCompat.getColor(mContext, R.color.design_default_color_error))
//    }

//    // TextField default 상태
//    fun TextInputLayout.setTextFieldDefault() {
//        this.error = null
//        setDefaultColor()
//        when(this.id) {
//            R.id.tf_id -> startIconDrawable = idIcon
//            R.id.tf_pw -> startIconDrawable = pwIcon
//            R.id.tf_pw_confirm -> startIconDrawable = pwIcon
//            R.id.tf_name -> startIconDrawable = nameIcon
//            R.id.tf_email -> startIconDrawable = emailIcon
//            R.id.tf_birth -> startIconDrawable = birthIcon
//        }
//    }
//
//    // TextField focus 상태
//    fun TextInputLayout.setTextFieldFocus() {
//        setVerifiedColor()
//        when(this.id) {
//            R.id.tf_id -> startIconDrawable = idIconFocus
//            R.id.tf_pw -> startIconDrawable = pwIconFocus
//            R.id.tf_pw_confirm -> startIconDrawable = pwIconFocus
//            R.id.tf_name -> startIconDrawable = nameIconFocus
//            R.id.tf_email -> startIconDrawable = emailIconFocus
//            R.id.tf_birth -> startIconDrawable = birthIconFocus
//        }
//    }

//    // TextField verified 상태
//    fun TextInputLayout.setTextFieldVerified() {
//        this.error = null
//        startIconDrawable = verifiedIcon
//        setVerifiedColor()
//    }
//
//    // TextField error 상태
//    fun TextInputLayout.setTextFieldError(errorMsg: String?) {
//        error = errorMsg
//        startIconDrawable = errorIcon
//        setErrorColor()
//    }
//
//    // TextField error 여부
//    fun TextInputLayout.isError(): Boolean {
//        return this.error != null
//    }

//    // 유효성 검사에 따른 TextField 상태 처리
//    fun TextInputLayout.validate(str: String) {
//        if(str.isEmpty())
//            this.setTextFieldVerified()
//        else {
//            this.setTextFieldError(str)
//        }
//    }
}