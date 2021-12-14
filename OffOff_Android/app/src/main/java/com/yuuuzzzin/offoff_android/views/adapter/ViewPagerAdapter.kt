package com.yuuuzzzin.offoff_android.views.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter

class ViewPagerAdapter(
    fragmentActivity: FragmentActivity, fragmentList: ArrayList<Fragment>,
    titleList: ArrayList<String>
) : FragmentStateAdapter(fragmentActivity) {

    var fragmentList: ArrayList<Fragment> = fragmentList
    val titleList: ArrayList<String> = titleList

    fun addFragment(fragment: Fragment, title: String) {
        fragmentList.add(fragment)
        titleList.add(title)
    }

    fun removeFragment() {
        fragmentList.removeLast()
        notifyItemRemoved(fragmentList.size)
    }

    fun getPageTitle(position: Int): String {
        return titleList[position]
    }

    override fun getItemCount(): Int {
        return fragmentList.size
    }

    override fun createFragment(position: Int): Fragment {
        return fragmentList[position]
    }
}