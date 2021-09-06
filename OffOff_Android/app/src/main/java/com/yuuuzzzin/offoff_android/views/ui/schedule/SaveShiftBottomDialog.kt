package com.yuuuzzzin.offoff_android.views.ui.schedule

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import androidx.fragment.app.activityViewModels
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.DialogBottomSaveShiftBinding
import com.yuuuzzzin.offoff_android.utils.CalendarUtils
import com.yuuuzzzin.offoff_android.viewmodel.ScheduleViewModel
import com.yuuuzzzin.offoff_android.views.adapter.ShiftIconListAdapter

class SaveShiftBottomDialog() : BottomSheetDialogFragment() {

    private var mBinding : DialogBottomSaveShiftBinding? = null
    private val binding get() = mBinding!!
    private lateinit var shiftIconListAdapter: ShiftIconListAdapter
    private val viewModel: ScheduleViewModel by activityViewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = DialogBottomSaveShiftBinding.inflate(inflater, container, false)
        val month =  arguments?.getString("month")
        val day =  arguments?.getString("day")
        val dayOfWeek =  CalendarUtils.WeekOfDayType.fromInt(arguments?.getInt("dayOfWeek")!!)
        binding.tvDate.text = "${month}월 ${day}일 ($dayOfWeek)"

        dialog?.window?.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)

        //initViewModel()
        initRV()

        return binding.root
    }

    private fun initViewModel() {


    }

    private fun initRV() {
        shiftIconListAdapter = ShiftIconListAdapter()
        binding.rvScheduleType.adapter =shiftIconListAdapter

        /* click listener 재정의 */
        shiftIconListAdapter.setOnScheduleTypeClickListener(object :
            ShiftIconListAdapter.OnShiftIconClickListener{
            override fun onShiftIconClick(view: View, shift: Shift) {
                TODO("Not yet implemented")
            }
        })

        viewModel.shiftList.observe(this, { shiftIconList ->
            shiftIconList?.let { shiftIconListAdapter.updateList(it) }
            Log.d("tag_realm_test", "shiftListIcon변화 감지")
        })
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}