package com.yuuuzzzin.offoff_android.view.ui

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.databinding.FragmentSettingsBinding
import com.yuuuzzzin.offoff_android.utils.Constants.toast
import com.yuuuzzzin.offoff_android.view.ui.member.LoginActivity

class SettingsFragment : Fragment() {

    private var mBinding : FragmentSettingsBinding? = null
    private val binding get() = mBinding!!


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        mBinding = FragmentSettingsBinding.inflate(inflater, container, false)

        initView()

        return mBinding?.root
    }

    private fun initView() {
        binding.menuLogout.setOnClickListener {
            OffoffApplication.pref.deleteToken() // 저장된 토큰 삭제

            val intent = Intent(context, LoginActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            startActivity(intent)
            requireActivity().finish()
            requireContext().toast("로그아웃되었습니다.")
        }
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}