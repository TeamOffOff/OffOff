package com.yuuuzzzin.offoff_android.views.ui.home

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.databinding.FragmentHomeBinding
import com.yuuuzzzin.offoff_android.utils.ImageUtils

class HomeFragment : Fragment() {

    private var mBinding: FragmentHomeBinding? = null
    private val binding get() = mBinding!!
    private lateinit var mContext: Context

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is MainActivity) {
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

        mBinding = FragmentHomeBinding.inflate(inflater, container, false)

        initView()
//        val toolbar : MaterialToolbar = binding. // 상단 툴바
//
//        toolbar.setOnMenuItemClickListener{
//            when(it.itemId) {
//                R.id.search -> {
//                    startActivity(Intent(context, SearchActivity::class.java))
//                    true
//                }
//                R.id.user -> {
//                    startActivity(Intent(context, UserActivity::class.java))
//                    true
//                }
//                else -> false
//            }
//        }

        return mBinding?.root
    }

    private fun initView() {
        binding.tvNickname.text = "${OffoffApplication.user.subInfo.nickname} 님"
        if (!OffoffApplication.user.subInfo.profile.isNullOrEmpty())
            binding.ivAvatar.setImageBitmap(ImageUtils.stringToBitmap(OffoffApplication.user.subInfo.profile!![0].body.toString()))
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}