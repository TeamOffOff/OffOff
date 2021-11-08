package com.yuuuzzzin.offoff_android.views.ui.member

import android.content.Intent
import android.os.Bundle
import androidx.fragment.app.Fragment
import com.google.android.material.tabs.TabLayoutMediator
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.ActivityFindInfoBinding
import com.yuuuzzzin.offoff_android.utils.base.BaseActivity
import com.yuuuzzzin.offoff_android.views.adapter.ViewPagerAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class FindInfoActivity : BaseActivity<ActivityFindInfoBinding>(R.layout.activity_find_info) {

    private lateinit var viewPagerAdapter: ViewPagerAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initView()
        initViewPager()
    }

    private fun initView() {
        binding.btBack.setOnClickListener {
            val intent = Intent(this, LoginActivity::class.java)
            startActivity(intent)
        }

        // finger swipe를 통한 프래그먼트 전환 막기 (구글에서 권장하지 않는다고 함.)
        binding.viewPager.isUserInputEnabled = false
    }

    private fun initViewPager() {
        val fragmentList: ArrayList<Fragment> = arrayListOf(
            FindIdFragment(),
            FindPwFragment()
        )

        val titleList: ArrayList<String> = arrayListOf(
            "아이디 찾기",
            "비밀번호 찾기"
        )

        val viewPagerAdapter = ViewPagerAdapter(this, fragmentList, titleList)
        binding.viewPager.adapter = viewPagerAdapter
        TabLayoutMediator(binding.tabLayout, binding.viewPager) { tab, position ->
            tab.text = viewPagerAdapter.getPageTitle(position)
        }.attach()
    }
}