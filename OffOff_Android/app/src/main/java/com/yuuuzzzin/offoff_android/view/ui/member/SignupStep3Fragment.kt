package com.yuuuzzzin.offoff_android.view.ui.member

import android.app.AlertDialog
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
import com.yuuuzzzin.offoff_android.utils.Constants
import com.yuuuzzzin.offoff_android.viewmodel.SignupViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignupStep3Fragment : Fragment() {

    private var mBinding: FragmentSignupStep3Binding? = null
    private val binding get() = mBinding!!
    private val signupViewModel: SignupViewModel by activityViewModels()
    private lateinit var mContext: Context

    override fun onAttach(context: Context) {
        super.onAttach(context)
            mContext = context
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = FragmentSignupStep3Binding.inflate(inflater, container, false)
        binding.viewModel = signupViewModel
        binding.lifecycleOwner = viewLifecycleOwner
        binding.btProfile.setOnClickListener {
            showDialog()
        }

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

    private fun showDialog() {

        val array = arrayOf(Constants.PROFILE_OPTION1, Constants.PROFILE_OPTION2, Constants.PROFILE_OPTION3, Constants.PROFILE_OPTION4)
        val builder = AlertDialog.Builder(mContext)

        builder.setItems(array) { _, which ->
            val selected = array[which]

            try {
                when(which) {

                }

            } catch (e: IllegalArgumentException) {

            }
        }

        val dialog = builder.create()
        dialog.show()
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }
}