package com.yuuuzzzin.offoff_android.views.ui.member

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.viewModels
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentFindIdBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseFragment
import com.yuuuzzzin.offoff_android.viewmodel.BoardListViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class FindIdFragment : BaseFragment<FragmentFindIdBinding>(R.layout.fragment_find_id) {

    private val viewModel: BoardListViewModel by viewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return super.onCreateView(inflater, container, savedInstanceState)
    }

    private fun initView() {}

    private fun initViewModel() {
//        binding.viewModel = viewModel
//        viewModel.boardList.observe(viewLifecycleOwner, {
//            with(boardListAdapter) { submitList(it.toMutableList()) }
//        })
    }
}