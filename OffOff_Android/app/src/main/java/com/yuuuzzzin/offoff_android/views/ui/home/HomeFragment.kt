package com.yuuuzzzin.offoff_android.views.ui.home

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentHomeBinding
import com.yuuuzzzin.offoff_android.utils.ImageUtils
import com.yuuuzzzin.offoff_android.utils.base.BaseFragment

class HomeFragment : BaseFragment<FragmentHomeBinding>(R.layout.fragment_home) {

    private lateinit var callback: OnBackPressedCallback
    private var backPressedTime: Long = 0

//    override fun onAttach(context: Context) {
//        super.onAttach(context)
//        callback = object : OnBackPressedCallback(true) {
//            override fun handleOnBackPressed() {
//
//                // 백 버튼 2초 내 다시 클릭 시 앱 종료
//                if (System.currentTimeMillis() - backPressedTime < 2000) {
//                    activity!!.finish()
//                    return
//                }
//
//                // 백 버튼 최초 클릭 시
//                requireContext().toast("뒤로가기 버튼을 한 번 더 누르면 앱이 종료됩니다.")
//                backPressedTime = System.currentTimeMillis()
//
//            }
//        }
//
//        requireActivity().onBackPressedDispatcher.addCallback(this, callback)
//    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
    }

    private fun initView() {
        binding.tvNickname.text = "${OffoffApplication.user.subInfo.nickname} 님"
        if (!OffoffApplication.user.subInfo.profile.isNullOrEmpty()) {
            binding.ivAvatar.apply {
                setImageBitmap(ImageUtils.stringToBitmap(OffoffApplication.user.subInfo.profile!![0].body.toString()))
                clipToOutline = true
            }
        }
    }

}