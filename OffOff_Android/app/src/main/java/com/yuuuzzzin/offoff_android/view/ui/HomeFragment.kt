package com.yuuuzzzin.offoff_android.view.ui

import android.content.Intent
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toolbar
import androidx.activity.result.contract.ActivityResultContracts
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
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

        val toolbar : MaterialToolbar = binding.appbarHome // 상단 툴바

        toolbar.setOnMenuItemClickListener{
            when(it.itemId) {
                R.id.search -> {
                    startActivity(Intent(context, SearchActivity::class.java))
                    true
                }
                R.id.user -> {
                    startActivity(Intent(context, UserActivity::class.java))
                    true
                }
                else -> false
            }
        }

        return mBinding?.root
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}