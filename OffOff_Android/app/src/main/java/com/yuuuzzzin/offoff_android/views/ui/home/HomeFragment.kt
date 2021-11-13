package com.yuuuzzzin.offoff_android.views.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.yuuuzzzin.offoff_android.databinding.FragmentHomeBinding

class HomeFragment : Fragment() {

    private var mBinding : FragmentHomeBinding? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val binding = FragmentHomeBinding.inflate(inflater, container, false)
        mBinding = binding

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

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}