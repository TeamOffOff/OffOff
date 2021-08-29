package com.yuuuzzzin.offoff_android.view.ui.schedule

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.yuuuzzzin.offoff_android.databinding.ActivityScheduleTypeSettingBinding
import com.yuuuzzzin.offoff_android.proto.models.ScheduleType
import com.yuuuzzzin.offoff_android.view.adapter.ScheduleTypeSettingListAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ScheduleTypeSettingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityScheduleTypeSettingBinding
    private lateinit var scheduleTypeSettingListAdapter: ScheduleTypeSettingListAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityScheduleTypeSettingBinding.inflate(layoutInflater)

        initRV()
        initView()

        setContentView(binding.root)
    }

    private fun initRV() {
        scheduleTypeSettingListAdapter = ScheduleTypeSettingListAdapter()
        binding.rvScheduleType.adapter =scheduleTypeSettingListAdapter

        scheduleTypeSettingListAdapter.scheduleTypeList.addAll(
            listOf(
                ScheduleType("주", "14:00", "21:00"),
                ScheduleType("야", "14:00", "21:00"),
                ScheduleType("휴", "14:00", "21:00"),
                ScheduleType("주", "14:00", "21:00"),
                ScheduleType("야", "14:00", "21:00"),
                ScheduleType("휴", "14:00", "21:00"),
                ScheduleType("주", "14:00", "21:00"),
                ScheduleType("야", "14:00", "21:00"),
                ScheduleType("휴", "14:00", "21:00")
            )
        )
    }

    private fun initView() {
        binding.btAdd.setOnClickListener {
            val dialog = ScheduleTypeSettingDialog()
            dialog.show(supportFragmentManager, "custom_dialog")
        }
    }
}