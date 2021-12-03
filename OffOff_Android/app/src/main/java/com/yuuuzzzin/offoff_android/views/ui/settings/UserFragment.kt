package com.yuuuzzzin.offoff_android.views.ui.settings

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.database.models.Option
import com.yuuuzzzin.offoff_android.databinding.FragmentUserBinding
import com.yuuuzzzin.offoff_android.utils.RecyclerViewUtils
import com.yuuuzzzin.offoff_android.utils.UserPostType.MY_BOOKMARK_POST
import com.yuuuzzzin.offoff_android.utils.UserPostType.MY_COMMENT_POST
import com.yuuuzzzin.offoff_android.utils.UserPostType.MY_POST
import com.yuuuzzzin.offoff_android.utils.base.BaseFragment
import com.yuuuzzzin.offoff_android.views.adapter.OptionListAdapter
import com.yuuuzzzin.offoff_android.views.ui.user.UserPostActivity
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class UserFragment : BaseFragment<FragmentUserBinding>(R.layout.fragment_user) {

    private lateinit var optionListAdapter: OptionListAdapter
    private val optionList = arrayListOf(Option(MY_POST), Option(MY_COMMENT_POST), Option(MY_BOOKMARK_POST))

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initRV()
        initView()
    }

    private fun initView() {
        binding.tvUserActivity.text = "${OffoffApplication.user.subInfo.nickname} 님의 활동"
    }

    private fun initRV() {
        optionListAdapter = OptionListAdapter(optionList)

        val spaceDecorationComment = RecyclerViewUtils.VerticalSpaceItemDecoration(16) // 아이템 사이의 거리
        binding.rvOption.apply {
            adapter = optionListAdapter
            layoutManager = LinearLayoutManager(context)
            addItemDecoration(spaceDecorationComment)
            hasFixedSize()
            //isNestedScrollingEnabled = false
        }

        optionListAdapter.setOnOptionClickListener(object :
            OptionListAdapter.OnOptionClickListener {
            override fun onClickOption(item: Option, position: Int) {
                val intent = Intent(mContext, UserPostActivity::class.java)
                intent.putExtra("option", item.title)
                startActivity(intent)
            }
        })
    }
}