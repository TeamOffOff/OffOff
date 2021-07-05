package com.yuuuzzzin.offoff_android.view.ui

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentBoardsBinding
import com.yuuuzzzin.offoff_android.databinding.FragmentHomeBinding

class BoardsFragment : Fragment() {

    private var mBinding : FragmentBoardsBinding? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val binding = FragmentBoardsBinding.inflate(inflater, container, false)

        mBinding = binding

        return mBinding?.root
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}