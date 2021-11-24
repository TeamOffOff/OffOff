package com.yuuuzzzin.offoff_android.views.ui.member

import androidx.fragment.app.viewModels
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentFindIdBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseFragment
import com.yuuuzzzin.offoff_android.viewmodel.BoardListViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class FindIdFragment : BaseFragment<FragmentFindIdBinding>(R.layout.fragment_find_id) {

    private val viewModel: BoardListViewModel by viewModels()

    override fun initView() {}

    override fun initViewModel() {
//        binding.viewModel = viewModel
//        viewModel.boardList.observe(viewLifecycleOwner, {
//            with(boardListAdapter) { submitList(it.toMutableList()) }
//        })
    }
}