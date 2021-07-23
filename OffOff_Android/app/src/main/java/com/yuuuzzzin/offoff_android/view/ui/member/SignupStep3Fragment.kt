package com.yuuuzzzin.offoff_android.view.ui.member

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep3Binding
import com.yuuuzzzin.offoff_android.viewmodel.SignupViewModel

class SignupStep3Fragment : Fragment() {

    private var mBinding: FragmentSignupStep3Binding? = null
    private val binding get() = mBinding!!
    private val signupViewModel: SignupViewModel by activityViewModels()
    private lateinit var mContext: Context

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is SignupActivity)
            mContext = context
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = FragmentSignupStep3Binding.inflate(inflater, container, false)
        binding.viewModel = signupViewModel
        binding.lifecycleOwner = viewLifecycleOwner

        return binding.root
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

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }
}