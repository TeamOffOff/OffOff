package com.yuuuzzzin.offoff_android.view.ui

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.DialogBottomBinding
import com.yuuuzzzin.offoff_android.proto.models.ScheduleType
import com.yuuuzzzin.offoff_android.utils.CalendarUtils
import com.yuuuzzzin.offoff_android.view.adapter.ScheduleTypeListAdapter

class BottomDialog() : BottomSheetDialogFragment() {

    private var mBinding : DialogBottomBinding? = null
    private val binding get() = mBinding!!
    private lateinit var scheduleTypeListAdapter: ScheduleTypeListAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        dialog?.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        setStyle(STYLE_NORMAL, R.style.CustomBottomSheetDialogTheme)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = DialogBottomBinding.inflate(inflater, container, false)
        val month =  arguments?.getString("month")
        val day =  arguments?.getString("day")
        val dayOfWeek =  CalendarUtils.WeekOfDayType.fromInt(arguments?.getInt("dayOfWeek")!!)
        binding.tvDate.text = "${month}월 ${day}일 ($dayOfWeek)"

        setRV()

        return binding.root
    }

    private fun setRV() {
        scheduleTypeListAdapter = ScheduleTypeListAdapter()
        binding.rvScheduleType.adapter =scheduleTypeListAdapter

        scheduleTypeListAdapter.scheduleTypeList.addAll(
            listOf(ScheduleType("주", null, null),
                ScheduleType("야", null, null),
                ScheduleType("휴", null, null),
                ScheduleType("주", null, null),
                ScheduleType("야", null, null),
                ScheduleType("휴", null, null),
                ScheduleType("주", null, null),
                ScheduleType("야", null, null),
                ScheduleType("휴", null, null))
        )

        /*board click listener 재정의*/
        scheduleTypeListAdapter.setOnScheduleTypeClickListener(object :
            ScheduleTypeListAdapter.OnScheduleTypeClickListener{
            override fun onScheduleTypeClick(view: View, scheduleType: ScheduleType) {

            }
        })
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}