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
        initView()
        initViewModel()

        return binding.root
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

    open fun initView() {}
    open fun initViewModel() {}

}