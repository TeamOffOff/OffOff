package com.yuuuzzzin.offoff_android.view.ui.schedule

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.format.DateUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.CalendarDayBinding
import com.yuuuzzzin.offoff_android.databinding.FragmentScheduleBinding
import jp.kuluna.calendarviewpager.CalendarPagerAdapter
import jp.kuluna.calendarviewpager.CalendarViewPager
import jp.kuluna.calendarviewpager.Day
import jp.kuluna.calendarviewpager.DayState
import java.util.*

class ScheduleFragment : Fragment() {

    private var mBinding: FragmentScheduleBinding? = null
    private val binding get() = mBinding!!

    lateinit var calendar: CalendarViewPager
    private val bottomDialog = CalendarBottomDialog()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = FragmentScheduleBinding.inflate(inflater, container, false)

        initToolbar()
        initCalendar()

        return binding.root
    }

    private fun initToolbar() {
        val toolbar: MaterialToolbar = binding.appbar // 상단 툴바
        toolbar.setOnMenuItemClickListener {
            when (it.itemId) {
                R.id.action_add -> {
                    startActivity(Intent(context, AddScheduleActivity::class.java))
                    true
                }
                R.id.action_set -> {
                    startActivity(Intent(context, ScheduleTypeSettingActivity::class.java))
                    true
                }
                else -> false
            }
        }
    }

    private fun initCalendar() {
        calendar = binding.cvCalendar
        calendar.adapter = CalendarAdapter(requireContext())
        setDateHeader(Calendar.getInstance())

        // 캘린더 셀 클릭 리스너
        calendar.onDayClickListener = { day: Day ->
            val bundle = Bundle()
            bundle.putString("month",(day.calendar.get(Calendar.MONTH) + 1).toString())
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
    }

    // 캘린더의 헤더 설정
    private fun setDateHeader(calendar: Calendar) {
        binding.tvMonth.text = DateUtils.formatDateTime(
            requireContext(), calendar.timeInMillis,
            DateUtils.FORMAT_SHOW_YEAR or DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_NO_MONTH_DAY)
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

}

class CalendarAdapter(context: Context) : CalendarPagerAdapter(context) {
    override fun onCreateView(parent: ViewGroup, viewType: Int): View {
        return LayoutInflater.from(context).inflate(R.layout.calendar_day, parent, false)
    }

    override fun onBindView(view: View, day: Day) {
        val tvDate = CalendarDayBinding.bind(view).tvDate
        val icon = CalendarDayBinding.bind(view).tvScheduleType

        if (day.state == DayState.ThisMonth) {
            view.visibility = View.VISIBLE
            tvDate.text = day.calendar.get(Calendar.DAY_OF_MONTH).toString()
            icon.visibility = if (day.calendar.get(Calendar.DAY_OF_MONTH) == 1 || day.calendar.get(Calendar.DAY_OF_MONTH) ==3 || day.calendar.get(Calendar.DAY_OF_MONTH) ==12 ||
                day.calendar.get(Calendar.DAY_OF_MONTH) ==16 || day.calendar.get(Calendar.DAY_OF_MONTH) ==  20 || day.calendar.get(Calendar.DAY_OF_MONTH) == 28 ||
                day.calendar.get(Calendar.DAY_OF_MONTH) ==25 || day.calendar.get(Calendar.DAY_OF_MONTH) ==  29 || day.calendar.get(Calendar.DAY_OF_MONTH) == 30) View.VISIBLE else View.GONE
        } else {
            view.visibility = View.INVISIBLE
        }
    }

}