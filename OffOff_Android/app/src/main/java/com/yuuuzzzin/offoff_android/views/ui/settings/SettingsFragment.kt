package com.yuuuzzzin.offoff_android.views.ui.settings

import android.content.Intent
import android.os.Bundle
import android.view.View
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSettingsBinding
import com.yuuuzzzin.offoff_android.utils.Constants.toast
import com.yuuuzzzin.offoff_android.utils.base.BaseFragment
import com.yuuuzzzin.offoff_android.views.ui.member.LoginActivity

class SettingsFragment : BaseFragment<FragmentSettingsBinding>(R.layout.fragment_settings) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initView()
    }

    private fun initView() {
        binding.tvLogout.setOnClickListener {
            OffoffApplication.pref.deleteToken() // 저장된 토큰 삭제

            val intent = Intent(context, LoginActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            startActivity(intent)
            requireActivity().finish()
            requireContext().toast("로그아웃되었습니다.")
        }
    }
}