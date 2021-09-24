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
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.appbar.MaterialToolbar
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.CalendarDayBinding
import com.yuuuzzzin.offoff_android.databinding.FragmentScheduleBinding
import com.yuuuzzzin.offoff_android.viewmodel.ScheduleViewModel
import dagger.hilt.android.AndroidEntryPoint
import jp.kuluna.calendarviewpager.*
import java.util.*
import kotlin.properties.Delegates

lateinit var calendar: CalendarViewPager

@AndroidEntryPoint
class ScheduleFragment : Fragment() {

    private var mBinding: FragmentScheduleBinding? = null
    private val binding get() = mBinding!!
    private val viewModel: ScheduleViewModel by activityViewModels()
    private lateinit var bottomDialog: SaveShiftBottomDialog

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        mBinding = FragmentScheduleBinding.inflate(inflater, container, false)

        initToolbar()
        initCalendar()

        bottomDialog = SaveShiftBottomDialog(calendar)
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
            (calendar.adapter as CalendarAdapter).selectedDate =
                (calendar.adapter as CalendarAdapter).selectedDay as Date

            Log.d("test_calendar", day.toString())
            val bundle = Bundle()
            bundle.putString("year", day.calendar.get(Calendar.YEAR).toString())
            bundle.putString("month", (day.calendar.get(Calendar.MONTH) + 1).toString())
            bundle.putString("day", day.calendar.get(Calendar.DAY_OF_MONTH).toString())
            bundle.putInt("dayOfWeek", day.calendar.get(Calendar.DAY_OF_WEEK))
            bottomDialog.arguments = bundle
            bottomDialog.show(parentFragmentManager, "calendar_bottom_dialog")
        }

        calendar.onDayLongClickListener = { day: Day ->
            true
        }

        // 다른 달로 넘어갈 때 리스너
        calendar.onCalendarChangeListener = { c: Calendar ->
            setDateHeader(c)
            (calendar.adapter as CalendarAdapter).notifyCalendarChanged()
        }

        // 스케줄이 바뀌는지 관찰
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

    private var viewContainer: ViewGroup? = null
    private var position by Delegates.notNull<Int>()
    lateinit var selectedDate: Date
    val viewModel: ScheduleViewModel = scheduleViewModel

    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        viewContainer = container
        this.position = position
        return super.instantiateItem(container, position)
    }

    override fun onCreateView(parent: ViewGroup, viewType: Int): View {
        return LayoutInflater.from(context).inflate(R.layout.calendar_day, parent, false)
    }

    override fun onBindView(view: View, day: Day) {
        //Log.d("tag_onBindView", view.toString() + '/' + day.toString())
        //Log.d("tag_onBindView", "캘린더 바인드")
        val tvDate = CalendarDayBinding.bind(view).tvDate
        val icon = CalendarDayBinding.bind(view).iconShift

        fun setThisMonthSelected(day: Day) = if (day.calendar.time == selectedDay) {
            view.setBackgroundResource(R.drawable.layout_border_calendar_selected)
        } else {
            view.setBackgroundResource(R.drawable.layout_border_calendar)
        }

        fun setOtherMonthSelected(day: Day) {
            view.alpha = 0.5F
            if (day.calendar.time == selectedDay) {
                Log.d("otherMonth_tag", "다른달")
                view.setBackgroundResource(R.drawable.layout_border_calendar_selected)
                view.alpha = 0.5F
                view.setBackgroundColor(
                    ContextCompat.getColor(
                        context,
                        R.color.gray
                    )
                )
                view.alpha = 0.5F
                //onDayClickLister?.invoke(day)
            } else {
                Log.d("otherMonth_tag", "다른달")
                view.setBackgroundResource(R.drawable.layout_border_calendar)
                view.alpha = 0.5F
                view.setBackgroundColor(
                    ContextCompat.getColor(
                        context,
                        R.color.gray
                    )
                )
                view.alpha = 0.5F
            }
            view.alpha = 0.5F
        }

        if (day.state == DayState.ThisMonth) {
            view.visibility = View.VISIBLE
            tvDate.text = day.calendar.get(Calendar.DAY_OF_MONTH).toString()

            setThisMonthSelected(day)

            if (day.isToday) view.setBackgroundColor(
                ContextCompat.getColor(
                    context,
                    R.color.gray
                )
            )
        } else {
            view.visibility = View.VISIBLE
            view.alpha = 0.5F
            tvDate.text = day.calendar.get(Calendar.DAY_OF_MONTH).toString()
            view.setOnClickListener {
                val thisTime =
                    day.calendar.get(Calendar.YEAR) * 12 + day.calendar.get(Calendar.MONTH)
                val compareTime = calendar.getCurrentCalendar()!!
                    .get(Calendar.YEAR) * 12 + calendar.getCurrentCalendar()!!.get(Calendar.MONTH)
                calendar.moveItemBy(thisTime.compareTo(compareTime))
                selectedDay = day.calendar.time
                onDayClickLister?.invoke(day)
                Log.d("tag_day", day.toString())
            }
            setOtherMonthSelected(day)
        }

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
            } else {
                icon.visibility = View.INVISIBLE
            }
        }
    }

    fun moveNextDate(): Date? {
        var cal: Calendar = Calendar.getInstance()
        cal.time = selectedDate
        cal.add(Calendar.DATE, 1)
        selectedDay = cal.time
        (calendar.adapter as CalendarAdapter).selectedDate =
            (calendar.adapter as CalendarAdapter).selectedDay as Date

        cal = Calendar.getInstance()
        cal.time = selectedDate

        val thisTime =
            cal.get(Calendar.YEAR) * 12 + cal.get(Calendar.MONTH)
        val compareTime = calendar.getCurrentCalendar()!!
            .get(Calendar.YEAR) * 12 + calendar.getCurrentCalendar()!!.get(Calendar.MONTH)
        calendar.moveItemBy(thisTime.compareTo(compareTime))

        return selectedDay
    }

    fun movePreviousDate(): Date? {
        var cal: Calendar = Calendar.getInstance()
        cal.time = selectedDate
        cal.add(Calendar.DATE, -1)
        selectedDay = cal.time
        (calendar.adapter as CalendarAdapter).selectedDate =
            (calendar.adapter as CalendarAdapter).selectedDay as Date

        cal = Calendar.getInstance()
        cal.time = selectedDate

        val thisTime =
            cal.get(Calendar.YEAR) * 12 + cal.get(Calendar.MONTH)
        val compareTime = calendar.getCurrentCalendar()!!
            .get(Calendar.YEAR) * 12 + calendar.getCurrentCalendar()!!.get(Calendar.MONTH)
        calendar.moveItemBy(thisTime.compareTo(compareTime))

        return selectedDay
    }

    fun initSelectedDay() {
        selectedDay = null
    }

//    fun notifyCalendarItemChanged() {
//        val views = this.viewContainer
//        if (views != null) {
//            Log.d("tag_scheduleChanged", "스케줄 추가 작업..")
//            (0 until views.childCount).forEach { i ->
//                Log.d("log_selectedDay", selectedDay.toString())
//                ((views.getChildAt(i) as? RecyclerView)?.adapter as? CalendarCellAdapter)?.updateItems(selectedDay)
//            }
//        }
//    }
}

class CalendarCellsAdapter(
    context: Context,
    calendar: Calendar,
    startingAt: CalendarPagerAdapter.DayOfWeek,
    preselectedDay: Date?
) : CalendarCellAdapter(context, calendar, startingAt, preselectedDay) {
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, day: Day) {
        TODO("Not yet implemented")
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        TODO("Not yet implemented")
    }

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
//        realm.executeTransaction {
//            val data = it.where(Shift::class.java).findAll()
//            Log.d("tag_realm_test", data.toString())
//        }
//    }
