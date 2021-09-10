package com.yuuuzzzin.offoff_android.views.ui.schedule

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.text.format.DateUtils
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.CalendarDayBinding
import com.yuuuzzzin.offoff_android.databinding.FragmentScheduleBinding
import com.yuuuzzzin.offoff_android.viewmodel.ScheduleViewModel
import dagger.hilt.android.AndroidEntryPoint
import jp.kuluna.calendarviewpager.CalendarPagerAdapter
import jp.kuluna.calendarviewpager.CalendarViewPager
import jp.kuluna.calendarviewpager.Day
import jp.kuluna.calendarviewpager.DayState
import java.util.*

@AndroidEntryPoint
class ScheduleFragment : Fragment() {

    private var mBinding: FragmentScheduleBinding? = null
    private val binding get() = mBinding!!
    private val viewModel: ScheduleViewModel by activityViewModels()
    lateinit var calendar: CalendarViewPager
    private val bottomDialog = SaveShiftBottomDialog()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        mBinding = FragmentScheduleBinding.inflate(inflater, container, false)

        initViewModel()
        initToolbar()
        initCalendar()

        return binding.root
    }

    private fun initViewModel() {
    }

//    private fun addDb() {
//
//        realm.executeTransaction{
//            with(it.createObject(Shift::class.java, "3")){
//                this.title = "D"
//                this.textColor = "black"
//                this.backgroundColor = "white"
//                this.startDate = "07:30"
//                this.endDate = "15:30"
//            }
//        }
//
//
//        realm.executeTransaction {
//            val data = it.where(Shift::class.java).findAll()
//            Log.d("tag_realm_test", data.toString())
//        }
//    }

    private fun initToolbar() {
        val toolbar: MaterialToolbar = binding.appbar // 상단 툴바
        toolbar.setOnMenuItemClickListener {
            when (it.itemId) {
                R.id.action_add -> {
                    startActivity(Intent(context, AddScheduleActivity::class.java))
                    true
                }
                R.id.action_set -> {
                    startActivity(Intent(context, ShiftSettingActivity::class.java))
                    true
                }
                R.id.action_allShiftList -> {
                    Log.d("tag_getAllShift", viewModel.getAllShift().toString())
                    true
                }
                R.id.action_insertShift -> {
                    // 임의의 Shift 삽입
                    viewModel.insertShift(
                        Shift(
                            viewModel.getNextId(),
                            "D",
                            "#FFFFFF",
                            "#000000",
                            "07:30",
                            "15:30"
                        )
                    )
                    true
                }
                R.id.action_deleteAllShifts -> {
                    viewModel.deleteAllShifts()
                    true
                }
                R.id.action_allScheduleList -> {
                    Log.d("tag_getAllSchedule", viewModel.getAllS().toString())
                    true
                }
                R.id.action_insertSchedule -> {
                    //viewModel.insertSchedule(SavedShift(viewModel.getNextScheduleId(), "D",Shift("#FFFFFF", "#000000", "07:30", "15:30"))
                    true
                }
                R.id.action_deleteAllSchedule -> {
                    viewModel.deleteAllSchedule()
                    true
                }
                else -> false
            }
        }
    }

    private fun initCalendar() {
        calendar = binding.cvCalendar
        calendar.adapter = CalendarAdapter(requireContext(), viewModel)
        setDateHeader(Calendar.getInstance())

        // 캘린더 셀 클릭 리스너
        calendar.onDayClickListener = { day: Day ->
            Log.d("test_calendar", day.toString())
            val bundle = Bundle()
            bundle.putString("year", day.calendar.get(Calendar.YEAR).toString())
            bundle.putString("month", (day.calendar.get(Calendar.MONTH) + 1).toString())
            bundle.putString("day", day.calendar.get(Calendar.DAY_OF_MONTH).toString())
            bundle.putInt("dayOfWeek", day.calendar.get(Calendar.DAY_OF_WEEK))
            bottomDialog.arguments = bundle
            bottomDialog.show(parentFragmentManager, "custom_dialog")
        }

        calendar.onDayLongClickListener = { day: Day ->

            true
        }

        // 다른 달로 넘어갈 때 리스너
        calendar.onCalendarChangeListener = { calendar: Calendar ->
            setDateHeader(calendar)
        }

        viewModel.scheduleChanged.observe(viewLifecycleOwner, { event ->
            event.getContentIfNotHandled()?.let {
                (calendar.adapter as CalendarAdapter).notifyCalendarChanged()
            }
        })
    }

    // 캘린더의 헤더 설정
    private fun setDateHeader(calendar: Calendar) {
        binding.tvMonth.text = DateUtils.formatDateTime(
            requireContext(), calendar.timeInMillis,
            DateUtils.FORMAT_SHOW_YEAR or DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_NO_MONTH_DAY
        )
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }
}

class CalendarAdapter(context: Context, scheduleViewModel: ScheduleViewModel) :
    CalendarPagerAdapter(context) {

    val viewModel: ScheduleViewModel = scheduleViewModel

    override fun onCreateView(parent: ViewGroup, viewType: Int): View {
        return LayoutInflater.from(context).inflate(R.layout.calendar_day, parent, false)
    }

    override fun onBindView(view: View, day: Day) {
        Log.d("tag_onBindView", view.toString() + '/' + day.toString())
        val tvDate = CalendarDayBinding.bind(view).tvDate
        val icon = CalendarDayBinding.bind(view).iconShift

        if (day.state == DayState.ThisMonth) {
            view.visibility = View.VISIBLE
            tvDate.text = day.calendar.get(Calendar.DAY_OF_MONTH).toString()

            // 저장된 근무 스케줄 띄우기
            viewModel.getSchedule(
                day.calendar.get(Calendar.YEAR),
                day.calendar.get(Calendar.MONTH) + 1,
                day.calendar.get(Calendar.DAY_OF_MONTH)
            ).let { savedShift ->
                if (savedShift != null) {
                    icon.visibility = View.VISIBLE
                    icon.text = savedShift.shift?.title
                    icon.setTextColor(Color.parseColor(savedShift.shift?.textColor!!))
                    icon.setBackgroundColor(
                        Color.parseColor(savedShift.shift?.backgroundColor!!)
                    )
                }
            }
        } else {
            // 이 부분이 나중에 이전, 다음 달 날짜셀 띄울 때 수정해야하는 부분인듯..?
            view.visibility = View.INVISIBLE
        }
    }
}
