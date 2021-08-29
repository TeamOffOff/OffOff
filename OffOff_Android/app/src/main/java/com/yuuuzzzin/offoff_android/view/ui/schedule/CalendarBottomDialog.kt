package com.yuuuzzzin.offoff_android.view.ui.schedule

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.yuuuzzzin.offoff_android.databinding.DialogBottomCalendarBinding
import com.yuuuzzzin.offoff_android.proto.models.ScheduleType
import com.yuuuzzzin.offoff_android.utils.CalendarUtils
import com.yuuuzzzin.offoff_android.view.adapter.ScheduleTypeListAdapter

class CalendarBottomDialog() : BottomSheetDialogFragment() {

    private var mBinding : DialogBottomCalendarBinding? = null
    private val binding get() = mBinding!!
    private lateinit var scheduleTypeListAdapter: ScheduleTypeListAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = DialogBottomCalendarBinding.inflate(inflater, container, false)
        val month =  arguments?.getString("month")
        val day =  arguments?.getString("day")
        val dayOfWeek =  CalendarUtils.WeekOfDayType.fromInt(arguments?.getInt("dayOfWeek")!!)
        binding.tvDate.text = "${month}월 ${day}일 ($dayOfWeek)"

        dialog?.window?.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)

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

        /* click listener 재정의 */
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