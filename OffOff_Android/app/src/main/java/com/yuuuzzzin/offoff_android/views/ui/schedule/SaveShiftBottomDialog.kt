package com.yuuuzzzin.offoff_android.views.ui.schedule

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import androidx.fragment.app.activityViewModels
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.yuuuzzzin.offoff_android.database.models.SavedShift
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.DialogBottomSaveShiftBinding
import com.yuuuzzzin.offoff_android.utils.CalendarUtils
import com.yuuuzzzin.offoff_android.viewmodel.ScheduleViewModel
import com.yuuuzzzin.offoff_android.views.adapter.ShiftIconListAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SaveShiftBottomDialog() : BottomSheetDialogFragment() {

    private var mBinding: DialogBottomSaveShiftBinding? = null
    private val binding get() = mBinding!!
    private lateinit var shiftIconListAdapter: ShiftIconListAdapter
    private val viewModel: ScheduleViewModel by activityViewModels()
    private lateinit var year: String
    private lateinit var month: String
    private lateinit var day: String
    private lateinit var dayOfWeek: String


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = DialogBottomSaveShiftBinding.inflate(inflater, container, false)
        year = arguments?.getString("year").toString()
        month = arguments?.getString("month").toString()
        day = arguments?.getString("day").toString()
        dayOfWeek = CalendarUtils.WeekOfDayType.fromInt(arguments?.getInt("dayOfWeek")!!).toString()
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
        binding.rvScheduleType.adapter = shiftIconListAdapter

        /* click listener 재정의 */
        shiftIconListAdapter.setOnScheduleTypeClickListener(object :
            ShiftIconListAdapter.OnShiftIconClickListener {
            override fun onShiftIconClick(view: View, shift: Shift) {
                viewModel.insertSchedule(
                    SavedShift(
                        id = viewModel.getNextScheduleId(),
                        date = (String.format("%04d-%02d-%02d", year.toInt(), month.toInt(), day.toInt())),
                        shift = shift
                    )
                )
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