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
import jp.kuluna.calendarviewpager.CalendarViewPager
import java.util.*

@AndroidEntryPoint
class SaveShiftBottomDialog(calendar: CalendarViewPager) : BottomSheetDialogFragment() {

    private var mBinding: DialogBottomSaveShiftBinding? = null
    private val binding get() = mBinding!!
    private lateinit var shiftIconListAdapter: ShiftIconListAdapter
    private val viewModel: ScheduleViewModel by activityViewModels()
    private lateinit var year: String
    private lateinit var month: String
    private lateinit var day: String
    private lateinit var dayOfWeek: String
    private var id: Int? = null
    private var savedShift: SavedShift? = null

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
        id = null
        binding.tvDate.text = "${month}월 ${day}일 ($dayOfWeek)"
        dialog?.window?.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)

        initViewModel()

//        viewModel.getSchedule(year.toInt(), month.toInt(), day.toInt()).let { savedShift ->
//            if (savedShift != null) {
//                this.savedShift = viewModel.getSchedule(year.toInt(), month.toInt(), day.toInt())
//                id = savedShift.id
//            }
//        }

        binding.btPrevious.setOnClickListener {
            (calendar.adapter as? CalendarAdapter)?.movePreviousDate().let { date ->
                val cal: Calendar = Calendar.getInstance()
                cal.time = date
                year = cal.get(Calendar.YEAR).toString()
                month = (cal.get(Calendar.MONTH) + 1).toString()
                day = cal.get(Calendar.DAY_OF_MONTH).toString()
                dayOfWeek =
                    CalendarUtils.WeekOfDayType.fromInt(cal.get(Calendar.DAY_OF_WEEK)).toString()
                binding.tvDate.text = "${month}월 ${day}일 ($dayOfWeek)"
                initViewModel()
            }
        }

        binding.btNext.setOnClickListener {
            (calendar.adapter as? CalendarAdapter)?.moveNextDate().let { date ->
                val cal: Calendar = Calendar.getInstance()
                cal.time = date
                year = cal.get(Calendar.YEAR).toString()
                month = (cal.get(Calendar.MONTH) + 1).toString()
                day = cal.get(Calendar.DAY_OF_MONTH).toString()
                dayOfWeek =
                    CalendarUtils.WeekOfDayType.fromInt(cal.get(Calendar.DAY_OF_WEEK)).toString()
                binding.tvDate.text = "${month}월 ${day}일 ($dayOfWeek)"
                initViewModel()
            }
        }

        binding.btDelete.setOnClickListener {
            if (id != null) {
                viewModel.deleteSchedule(id!!)
                viewModel.scheduleChanged()
                dialog!!.dismiss()
            }
        }

        initRV()

        return binding.root
    }

    override fun dismiss() {
        (calendar.adapter as? CalendarAdapter)?.initSelectedDay()
        super.dismiss()
    }

    fun initViewModel() {
        Log.d("tag_initViewModel", "뷰모델 초기화")
        viewModel.getSchedule(year.toInt(), month.toInt(), day.toInt()).let { savedShift ->
            if (savedShift != null) {
                this.savedShift = viewModel.getSchedule(year.toInt(), month.toInt(), day.toInt())
                id = savedShift.id
            }
        }
        (calendar.adapter as? CalendarAdapter)?.notifyDataSetChanged()
    }

    private fun initRV() {
        shiftIconListAdapter = ShiftIconListAdapter()
        binding.rvScheduleType.adapter = shiftIconListAdapter

        /* click listener 재정의 */
        shiftIconListAdapter.setOnShiftIconClickListener(object :
            ShiftIconListAdapter.OnShiftIconClickListener {
            override fun onShiftIconClick(view: View, shift: Shift) {
                viewModel.insertSchedule(
                    SavedShift(
                        id = if (id != null) id else viewModel.getNextScheduleId(),
                        date = (String.format(
                            "%04d-%02d-%02d",
                            year.toInt(),
                            month.toInt(),
                            day.toInt()
                        )),
                        shift = shift
                    )
                )

                viewModel.scheduleChanged()
                dialog!!.dismiss()
            }
        })

        viewModel.shiftList.observe(this, { shiftIconList ->
            shiftIconList?.let { shiftIconListAdapter.updateList(it) }
            Log.d("tag_realm_test", "shiftListIcon 변화 감지")
        })
    }

    override fun onDestroyView() {
        mBinding = null
        (calendar.adapter as? CalendarAdapter)?.initSelectedDay()
        super.onDestroyView()
    }

}